require 'rspec'
require 'spec_helper'
require 'todoable'

RSpec.describe 'Todoable API wrapper' do
  let(:api) {
    Todoable::Api.new(
      user: 'frankkotsianas@gmail.com',
      pass: 'todoable'
    )
  }

  describe 'Authentication' do
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

  describe 'RESTful routes' do

    # Clean up after each test
    #
    # WARNING: this will clobber all lists on this account --
    # - use a dev account to do development, not your production account
    after(:each) do
      lists = api.lists
      lists.each do |l|
        api.delete_list(l.id)
      end
    end

    describe 'GET /lists' do
      before do
        api.new_list('todo-1')
        api.new_list('todo-2')
      end

      it 'retrieves all lists' do
        lists = api.lists
        expect(lists.length).to eq 2
        expect(lists.map(&:name)).to match_array ['todo-1', 'todo-2']
      end
    end

    describe 'POST /lists' do
      it 'creates a new list with the intended name' do
        new_list = api.new_list('test-list')
        expect(new_list.name).to eq 'test-list'
        expect(new_list.id).to_not eq nil
      end

      context 'when a name is not provided' do
        it 'raises an informative error' do
          expect {
            api.new_list()
          }.to raise_error(/provide a list name/)
        end
      end

      context 'when an API error is observed' do
        before do
          api.new_list('test-list')
        end

        it 'raises the error to the user' do
          expect {
            api.new_list('test-list')
          }.to raise_error(/name has already been taken/)
        end
      end
    end

    describe 'GET /lists/:list_id' do
      let!(:new_list) { api.new_list('todo') }

      it 'returns the list and items in it' do
        list = api.list(new_list.id)

        expect(list).to_not eq nil
        expect(list.items).to eq []
      end

      context 'when the list is not found' do
        it 'returns nil' do
          list = api.list('1234')
          expect(list).to eq nil
        end
      end

      context 'when a list_id is not given' do
        it 'raises an informative error' do
          expect {
            api.list()
          }.to raise_error /provide a list ID/
        end
      end
    end

    describe 'PATCH /lists/:list_id' do
      let!(:new_list) { api.new_list('todo') }

      it 'updates the list and returns the updated list' do
        updated = api.update_list(new_list.id, 'not-todo')

        expect(updated).to eq true
      end

      context 'when the list_id is not given' do
        it 'raises an informative error' do
          expect {
            api.list()
          }.to raise_error /provide a list ID/
        end
      end

      context 'when the list is not found' do
        it 'raises an informative error' do
          expect {
            api.update_list('1234', 'not-todo')
          }.to raise_error /not found/
        end
      end
    end

    describe 'DELETE /lists/:list_id' do
      let!(:list) { api.new_list('delete-me') }

      it 'deletes the list and all items in it' do
        list_id = list.id
        expect {
          api.delete_list(list_id)
        }.to change {
          api.list(list_id)
        }
          .from(anything)
          .to(nil)
      end
    end

    describe 'POST /lists/:list_id/items' do
      let!(:list) { api.new_list('todo') }

      it 'adds the item to the desired list' do
        success = api.new_item(list.id, 'Get milk')

        expect(success).to eq true
        expect(api.list(list.id).items.map(&:name)).to match_array /Get milk/
      end

      context 'when a list ID is not provided' do
        it 'raises an informative error' do
          expect {
            api.new_item(nil, 'Get milk')
          }.to raise_error /provide a list ID/
        end
      end

      context 'when an item name is empty' do
        it 'raises an informative error' do
          expect {
            api.new_item(list.id, '')
          }.to raise_error /provide an item title/
        end
      end

      context 'when an item name is not provided' do
        it 'raises an informative error' do
          expect {
            api.new_item(list.id, nil)
          }.to raise_error /provide an item title/
        end
      end

      context 'when the list is not found' do
        it 'raises an informative error' do
          expect {
            api.new_item('1234', 'Get milk')
          }.to raise_error /not found/
        end
      end
    end

    describe 'PUT /lists/:list_id/items/:item_id/finish' do
      let!(:new_list) { api.new_list('todo') }
      before do
        api.new_item(new_list.id, 'Get milk')
      end

      it 'marks the item as finished' do
        list_with_item = api.list(new_list.id)
        item_id = list_with_item.items.first.id

        success = api.finish_item(new_list.id, item_id)
        list_with_item = api.list(new_list.id)
        completed_item = list_with_item.items.select {|i| i.id == item_id}[0]

        expect(success).to eq true
        expect(completed_item.finished_at).to_not eq nil
      end

      context 'when a list ID is not provided' do
        it 'raises an informative error' do
          expect {
            api.finish_item(nil, '5678')
          }.to raise_error /provide a list ID/
        end
      end

      context 'when an item ID is not provided' do
        it 'raises an informative error' do
          expect {
            api.finish_item(new_list.id, nil)
          }.to raise_error /provide an item ID/
        end
      end

      context 'when the list or item is not found' do
        it 'raises an informative error' do
          expect {
            api.finish_item('1234', '5678')
          }.to raise_error /not found/
        end
      end
    end

    describe 'DELETE /lists/:list_id/items/:item_id' do
      let!(:list) { api.new_list('todo') }
      before do
        api.new_item(list.id, 'Get milk')
      end

      it 'deletes the item from the list' do
        list_with_item = api.list(list.id)
        item_id = list_with_item.items.first.id

        expect {
          api.delete_item(list.id, item_id)
        }.to change {
          api.list(list.id).items.length
        }
          .from(1)
          .to(0)
      end

      context 'when a list ID is not provided' do
        it 'raises an informative error' do
          expect {
            api.delete_item(nil, '5678')
          }.to raise_error /provide a list ID/
        end
      end

      context 'when an item ID is not provided' do
        it 'raises an informative error' do
          expect {
            api.delete_item(list.id, nil)
          }.to raise_error /provide an item ID/
        end
      end

      context 'when the list or item is not found' do
        it 'raises an informative error' do
          expect {
            api.delete_item('1234', '5678')
          }.to raise_error /not found/
        end
      end
    end
  end

end
