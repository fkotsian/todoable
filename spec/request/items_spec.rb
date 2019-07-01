require 'spec_helper'

RSpec.describe 'Items routes' do
  let(:api) {
    Todoable::Api.new(
      user: 'frankkotsianas@gmail.com',
      pass: 'todoable'
    )
  }

  set_list_cleaning!

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
