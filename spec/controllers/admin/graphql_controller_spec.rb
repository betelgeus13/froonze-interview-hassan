require 'rails_helper'

RSpec.describe Admin::GraphqlController, type: :controller do
  describe '#track_action' do
    let(:controller) { described_class.new }
    let(:ahoy) { double('Ahoy::Tracker') }

    before do
      allow(controller).to receive(:ahoy).and_return(ahoy)
      allow(ahoy).to receive(:track)
      controller.params = {
        operationName: 'exampleOperation',
        method: 'POST',
        url: 'http://example.com/graphql',
        query: 'query { someField }'
      }
    end

    context 'when operationName is not in the excluded list' do
      it 'tracks the action using Ahoy' do
        controller.send(:track_action)

        expect(ahoy).to have_received(:track).with('exampleOperation', {
          method: 'POST',
          url: 'http://example.com/graphql',
          query: 'query { someField }'
        })
      end
    end

    context 'when operationName is in the excluded list' do
      before do
        controller.params[:operationName] = 'teamMemberSearch'
      end

      it 'does not track the action using Ahoy' do
        controller.send(:track_action)

        expect(ahoy).not_to have_received(:track)
      end
    end
  end
end
