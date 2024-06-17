require 'rails_helper'

RSpec.describe 'Pokers API', type: :request do
  describe 'POST /pokers/api/v1/cards/check' do
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    shared_examples 'valid poker hands' do |cards, expected_results|
      let(:valid_cases) { { cards: } }

      it 'returns the correct hand type for valid poker hands' do
        post('/pokers/api/v1/cards/check', params: valid_cases.to_json, headers:)
        expect(response).to be_successful
        json_response = JSON.parse(response.body)

        expected_results.each_with_index do |expected_result, index|
          if json_response['result'][index].has_key?('error')
            expect(json_response['result'][index]['error']).to eq(expected_result[:error])
          else
            expect(json_response['result'][index]['hand']).to eq(expected_result[:hand])
            expect(json_response['result'][index]['best']).to eq(expected_result[:best])
          end
        end
      end
    end

    context 'with valid poker hands full' do
      it_behaves_like 'valid poker hands',
                      [
                        'S5 H10 D11 C12 C13', # High Card
                        'S9 H9 S2 S3 S4', # One Pair
                        'C9 D9 C10 D10 S13',      # Two Pair-
                        'C7 D7 H7 D13 S12',       # Three of a Kind-
                        'D1 D2 D3 D4 C5',         # Straight-
                        'C1 C2 C3 C4 C11', # Flush-
                        'C8 D8 H8 H12 D12',       # Full House-
                        'H6 D6 C6 S6 S1',         # Four of a Kind-
                        'H1 H2 H3 H4 H5'          # Straight Flush-
                      ],
                      [
                        { hand: 'high card', best: false },
                        { hand: 'one pair', best: false },
                        { hand: 'two pairs', best: false },
                        { hand: 'three of a kind', best: false },
                        { hand: 'straight', best: false },
                        { hand: 'flush', best: false },
                        { hand: 'full house', best: false },
                        { hand: 'four of a kind', best: false },
                        { hand: 'straight flush', best: true }
                      ]
    end

    context 'with valid poker hands 1' do
      it_behaves_like 'valid poker hands',
                      [
                        'H1 H2 H3 H4 H5',     # Straight Flush
                        'C10 D10 H10 S10 D2', # Four of a Kind
                        'S11 H11 D11 S4 D4'   # Full House
                      ],
                      [
                        { hand: 'straight flush', best: true },
                        { hand: 'four of a kind', best: false },
                        { hand: 'full house', best: false }
                      ]
    end

    context 'with valid poker hands 2' do
      it_behaves_like 'valid poker hands',
                      [
                        'H1 H12 H10 H5 H3',   # Flush
                        'S8 S7 H6 C5 S4',     # Straight
                        'S12 C12 D12 S5 C3'   # Three of a Kind
                      ],
                      [
                        { hand: 'flush', best: true },
                        { hand: 'straight', best: false },
                        { hand: 'three of a kind', best: false }
                      ]
    end

    context 'with valid poker hands 3' do
      it_behaves_like 'valid poker hands',
                      [
                        'H13 D13 C2 D2 H11',  # Two Pair
                        'C10 S10 S6 H4 H2',   # One Pair
                        'D1 D10 S9 C5 C4'     # High Card
                      ],
                      [
                        { hand: 'two pairs', best: true },
                        { hand: 'one pair', best: false },
                        { hand: 'high card', best: false }
                      ]
    end

    context 'with valid poker hands 4' do
      it_behaves_like 'valid poker hands',
                      [
                        'H1 H13 H12 H11 H10', # Straight Flush
                        'S9 S8 S7 S6 S2',     # Flush
                        'D13 C12 D11 D10 D9'  # Straight
                      ],
                      [
                        { hand: 'straight flush', best: true },
                        { hand: 'flush', best: false },
                        { hand: 'straight', best: false }
                      ]
    end

    context 'with valid poker hands 5' do
      it_behaves_like 'valid poker hands',
                      [
                        'C3 D3 H3 S3 H9',     # Four of a Kind
                        'C4 D4 H4 S5 C6',     # Three of a kind
                        'D7 D8 D9 D10 D2' # Flush
                      ],
                      [
                        { hand: 'four of a kind', best: true },
                        { hand: 'three of a kind', best: false },
                        { hand: 'flush', best: false }
                      ]
    end

    context 'with nil input' do
      it_behaves_like 'valid poker hands',
                      [
                        '',
                        'C4 D4 H4 S5 C6', # Three of a kind
                        'D7 D8 D9 D10 D2' # Flush
                      ],
                      [
                        { error: 'input is nil' },
                        { hand: 'three of a kind', best: false },
                        { hand: 'flush', best: true }
                      ]
    end

    context 'with invalid suit' do
      it_behaves_like 'valid poker hands',
                      [
                        'C3 D3 H3 S3 H9',     # Four of a Kind
                        'C4 D4 H4 S5 K6',     #
                        'D7 D8 D9 D10 D2' # Flush
                      ],
                      [
                        { hand: 'four of a kind', best: true },
                        { error: 'Invalid suit: K6' },
                        { hand: 'flush', best: false }
                      ]
    end

    context "with invalid card's length" do
      it_behaves_like 'valid poker hands',
                      [
                        'C3 D3 H3 S3 H9',     # Four of a Kind
                        'C4 D4 H4 S5 C6',     # Three of a kind
                        'D7  D10 D2' # Flush
                      ],
                      [
                        { hand: 'four of a kind', best: true },
                        { hand: 'three of a kind', best: false },
                        { error: "Invalid card's length" }
                      ]
    end

    context 'with invalid number' do
      it_behaves_like 'valid poker hands',
                      [
                        'C3 D3 H3 S3 H9', # Four of a Kind
                        'C4 D4890 H4 S5 C6', # Three of a kind
                        'D7 D8 D9 D10 D2' # Flush
                      ],
                      [
                        { hand: 'four of a kind', best: true },
                        { error: 'Invalid number: D4890' },
                        { hand: 'flush', best: false }
                      ]
    end
  end
end
