require 'spec_helper'

RSpec.describe 'Authentication' do
  let(:api) {
    Todoable::Api.new(
      user: 'frankkotsianas@gmail.com',
      pass: 'todoable'
    )
  }

  it 'fetches a token via basic auth' do
    tok, _ = api.new_token
    expect(tok).to_not eq nil
  end

  it 'stores the token and expiry time' do
    tok, expiry = api.new_token
    expect(api.token).to eq tok
    expect(api.token_expiration).to eq expiry
  end

  it 'refreshes the auth token if it is expired' do
    expired_api = Todoable::Api.new(
      token: "x"*16,
      expiry: (Time.now - 21 * 60).to_s,
    )

    expect(expired_api).to receive(:new_token)
    expired_api.token
  end

  context 'if no username or password is set in the environment' do
    it 'raises an informative error' do
      api_from_env = Todoable::Api.new()
      expect {
        api_from_env.token
      }.to raise_error /Please set Todoable API username and password/
    end
  end
end
