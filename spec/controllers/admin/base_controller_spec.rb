require 'rails_helper'

RSpec.describe Admin::BaseController, type: :controller do
  describe '#track_action' do
    let(:controller) { described_class.new }
    let(:ahoy) { double('Ahoy::Tracker') }

    before do
      allow(controller).to receive(:ahoy).and_return(ahoy)
      allow(ahoy).to receive(:track)
      controller.params = { controller: 'some_controller', action: 'some_action' }
    end

    it 'tracks the action using Ahoy' do
      controller.send(:track_action)

      expect(ahoy).to have_received(:track).with('Ran action', {
        controller: 'some_controller',
        action: 'some_action',
      })
    end
  end
end
