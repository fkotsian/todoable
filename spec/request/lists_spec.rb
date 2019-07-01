require 'spec_helper'

RSpec.describe 'Lists routes' do
  let(:api) {
    Todoable::Api.new(
      user: 'frankkotsianas@gmail.com',
      pass: 'todoable'
    )
  }

  set_list_cleaning!

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
end
