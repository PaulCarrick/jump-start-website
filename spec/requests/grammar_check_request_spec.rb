require 'rails_helper'

RSpec.describe 'Checking spelling and grammar', type: :request do
  let!(:setup) { SiteSetup.find_by(configuration_name: 'default') || create(:site_setup) }
  let(:problem) { { offset: 0, length: 4, message: 'Use “These”.', short_message: '', replacements: [ 'These' ], rule: 'THIS_NNS', kind: 'grammar' } }

  it 'returns the problems to administrators' do
    allow(GrammarCheck).to receive(:check).with('This are apples.').and_return([ problem ])
    sign_in create(:user, access: 'super')
    post admin_grammar_check_path, params: { text: 'This are apples.' }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['problems'].first).to include('offset' => 0, 'replacements' => [ 'These' ])
  end

  it 'passes on a message when the checker fails' do
    allow(GrammarCheck).to receive(:check).and_raise(GrammarCheck::Error, 'The spelling and grammar checker is busy.')
    sign_in create(:user, access: 'super')
    post admin_grammar_check_path, params: { text: 'Hello.' }, as: :json
    expect(response).to have_http_status(:service_unavailable)
    expect(response.parsed_body['error']).to include('busy')
  end

  it 'is only for administrators' do
    expect(GrammarCheck).not_to receive(:check)
    sign_in create(:user, access: 'read_only')
    post admin_grammar_check_path, params: { text: 'Hello.' }, as: :json
    expect(response).to have_http_status(:forbidden)
  end
end
