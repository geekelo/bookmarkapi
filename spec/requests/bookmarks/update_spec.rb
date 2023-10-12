# frozen_string_literal: true

# spec/requests/bookmarks/update_spec.rb

require 'rails_helper'
context 'authenticated user' do
  describe 'PUT /bookmarks' do
    let!(:bookmark) { Bookmark.create(url: 'https://rubyyagi.com', title: 'Ruby Yagi') }

    # Define a user object (replace 'username' and 'authentication_token' with actual values)
    let!(:user) { User.create(username: 'username', authentication_token: 'token') }

    scenario 'valid bookmark attributes' do
      put "/bookmarks/#{bookmark.id}", params: {
        bookmark: {
          url: 'https://fluffy.es',
          title: 'Fluffy'
        }
      }, headers: { 'X-Username': user.username, 'X-Token': user.authentication_token }

      expect(response.status).to eq(200)

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:url]).to eq('https://fluffy.es')
      expect(json[:title]).to eq('Fluffy')

      expect(bookmark.reload.title).to eq('Fluffy')
      expect(bookmark.reload.url).to eq('https://fluffy.es')
    end

    scenario 'invalid bookmark attributes' do
      put "/bookmarks/#{bookmark.id}", params: {
        bookmark: {
          url: '',
          title: 'Fluffy'
        }
      }, headers: { 'X-Username': user.username, 'X-Token': user.authentication_token }

      expect(response.status).to eq(422)

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:url]).to eq(["can't be blank"])

      expect(bookmark.reload.title).to eq('Ruby Yagi')
      expect(bookmark.reload.url).to eq('https://rubyyagi.com')
    end
  end

  # scenario with unauthenticated user
  context 'unauthenticated user' do
    let!(:bookmark) { Bookmark.create(url: 'https://rubyyagi.com', title: 'Ruby Yagi') }
    scenario 'valid bookmark attributes' do
      put "/bookmarks/#{bookmark.id}", params: {
        bookmark: {
          url: 'https://fluffy.es',
          title: 'Fluffy'
        }
      }

      # response should have HTTP Status 403 Forbidden
      expect(response.status).to eq(403)

      # response contain error message
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:message]).to eq('Invalid User')
    end
  end
end
