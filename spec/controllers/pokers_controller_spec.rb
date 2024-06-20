require 'rails_helper'
require 'support/shared_examples_for_pokers'

RSpec.describe WebPokersController, type: :controller do
  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'POST #check' do
    context 'with valid poker hand' do
      valid_cases = [
        { cards: 'H1 H13 H12 H11 H10', result: 'straight flush' },
        { cards: 'C7 C6 C5 C4 C3', result: 'straight flush' },
        { cards: 'C10 D10 H10 S10 D5', result: 'four of a kind' },
        { cards: 'D5 D6 H6 S6 C6', result: 'four of a kind' },
        { cards: 'S10 H10 D10 S4 D4', result: 'full house' },
        { cards: 'H9 C9 S9 H1 C1', result: 'full house' },
        { cards: 'H1 H12 H10 H5 H3', result: 'flush' },
        { cards: 'S13 S12 S11 S9 S6', result: 'flush' },
        { cards: 'S8 S7 H6 H5 S4', result: 'straight' },
        { cards: 'D6 S5 D4 H3 C2', result: 'straight' },
        { cards: 'S12 C12 D12 S5 C3', result: 'three of a kind' },
        { cards: 'C5 H5 D5 D12 C10', result: 'three of a kind' },
        { cards: 'H13 D13 C2 D2 H11', result: 'two pairs' },
        { cards: 'D11 S11 S10 C10 S9', result: 'two pairs' },
        { cards: 'C10 S10 S6 H4 H2', result: 'one pair' },
        { cards: 'H9 C9 H1 D12 D10', result: 'one pair' },
        { cards: 'D1 D10 S9 C5 C4', result: 'high card' },
        { cards: 'C13 D12 C11 H8 H7', result: 'high card' }
      ]

      valid_cases.each do |valid_case|
        include_examples 'valid poker hand', valid_case[:cards], valid_case[:result]
      end
    end

    context 'with invalid poker hand' do
      invalid_cases = [
        # Invalid card length
        { cards: 'H1 H13 H12 H11', error: "Invalid card's length" },
        { cards: 'H1 H13 H12 H11 H10 H9', error: "Invalid card's length" },

        # Invalid suit
        { cards: 'Z1 H13 H12 H11 H10', error: 'Invalid suit: Z1' },
        { cards: 'H1 H13 H12 H11 X10', error: 'Invalid suit: X10' },
        { cards: 'C1 C13 C12 C11 Z10', error: 'Invalid suit: Z10' },

        # Invalid number
        { cards: 'H14 H13 H12 H11 H10', error: 'Invalid number: H14' },
        { cards: 'H0 H13 H12 H11 H10', error: 'Invalid number: H0' },
        { cards: 'C14 C13 C12 C11 C10', error: 'Invalid number: C14' },

        # Duplicate cards
        { cards: 'H1 H1 H12 H11 H10', error: 'Repeated cards: H1' },
        { cards: 'D2 H13 H12 H11 D2', error: 'Repeated cards: D2' },
        { cards: 'C1 C1 C12 C11 C10', error: 'Repeated cards: C1' },

        # Nil input
        { cards: '', error: 'input is nil' },
        { cards: nil, error: 'input is nil' }
      ]

      invalid_cases.each do |invalid_case|
        include_examples 'invalid poker hand', invalid_case[:cards], invalid_case[:error]
      end
    end
  end
end
