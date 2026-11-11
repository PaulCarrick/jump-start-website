require 'rails_helper'

# The video the sidebar's "Video Tutorial" link opens is a file in the repository.
RSpec.describe 'Video tutorial', type: :request do
  it 'serves the video, its captions and its poster' do
    {
      'jump-start-website-tutorial.mp4' => 'video/mp4',
      'jump-start-website-tutorial.en.vtt' => 'text/vtt',
      'jump-start-website-tutorial-poster.webp' => 'image/webp'
    }.each do |name, type|
      expect(Rails.public_path.join('tutorial', name)).to exist
      get "/tutorial/#{name}"
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(type)
    end
  end
end
