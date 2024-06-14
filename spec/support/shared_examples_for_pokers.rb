RSpec.shared_examples "valid poker hand" do |cards, expected_result|
    it "returns the correct hand message" do
        post :check, params: { cards: cards}
        expect(response).to redirect_to(action: :index)
        expect(flash[:result]).to eq(expected_result)
    end
end

RSpec.shared_examples "invalid poker hand" do |cards, expected_error|

    it "returns an corresponding message" do 
        post :check, params: {cards: cards}
        expect(response).to redirect_to(action: :index)
        expect(flash[:error]).to eq(expected_error)
    end
end