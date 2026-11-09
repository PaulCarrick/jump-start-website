require 'rails_helper'
require 'webmock'

RSpec.describe GrammarCheck do
  include WebMock::API

  # Only this file fakes the internet; the rest of the suite is left alone.
  before do
    WebMock.enable!
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  after do
    WebMock.reset!
    WebMock.allow_net_connect!
    WebMock.disable!
  end
  let(:endpoint) { 'https://api.languagetool.org/v2/check' }
  let(:reply) do
    { matches: [
      { offset: 0, length: 4, message: 'Use “These”.', shortMessage: 'Grammar', replacements: [ { value: 'These' } ],
        rule: { id: 'THIS_NNS', category: { id: 'GRAMMAR' } } },
      { offset: 23, length: 6, message: 'Possible spelling mistake found.', shortMessage: 'Spelling mistake',
        replacements: %w[written writer write writes whiten wit].map { |value| { value: value } },
        rule: { id: 'MORFOLOGIK_RULE_EN_US', category: { id: 'TYPOS' } } }
    ] }.to_json
  end

  it 'sends the text and returns each problem with its place, message and suggestions' do
    stub = stub_request(:post, endpoint).with(body: { text: 'This are a apple. Paul writen this.', language: 'en-US' })
                                        .to_return(status: 200, body: reply)
    problems = described_class.check('This are a apple. Paul writen this.')
    assert_requested(stub)
    expect(problems.first).to include(offset: 0, length: 4, replacements: [ 'These' ], kind: 'grammar')
    expect(problems.last).to include(offset: 23, length: 6, kind: 'spelling')
    expect(problems.last[:replacements].size).to eq(5)
  end

  it 'uses your own LanguageTool when LANGUAGETOOL_URL is set' do
    stub = stub_request(:post, 'http://localhost:8010/v2/check').to_return(status: 200, body: { matches: [] }.to_json)
    ENV['LANGUAGETOOL_URL'] = 'http://localhost:8010'
    described_class.check('Hello there.')
    assert_requested(stub)
  ensure
    ENV.delete('LANGUAGETOOL_URL')
  end

  it 'sends nothing for empty text and refuses text that is too long' do
    expect(described_class.check(" \n")).to eq([])
    expect { described_class.check('a' * (GrammarCheck::MAX_CHARACTERS + 1)) }.to raise_error(GrammarCheck::Error, /too long/)
    assert_not_requested(:post, endpoint)
  end

  it 'says when the checker is busy or cannot be reached' do
    stub_request(:post, endpoint).to_return(status: 429)
    expect { described_class.check('Hello.') }.to raise_error(GrammarCheck::Error, /busy/)
    stub_request(:post, endpoint).to_timeout
    expect { described_class.check('Hello.') }.to raise_error(GrammarCheck::Error, /could not be reached/)
  end
end
