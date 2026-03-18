# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Procedural::Helpers::Production do
  subject(:production) do
    described_class.new(condition: 'if_error', action: 'retry_request', domain: :http, skill_id: 'skill-123')
  end

  describe '#initialize' do
    it 'assigns a UUID' do
      expect(production.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores condition and action' do
      expect(production.condition).to eq('if_error')
      expect(production.action).to eq('retry_request')
    end

    it 'starts with zero execution count' do
      expect(production.execution_count).to eq(0)
    end
  end

  describe '#execute!' do
    it 'increments execution count' do
      expect { production.execute!(success: true) }.to change(production, :execution_count).by(1)
    end

    it 'increments success count on success' do
      expect { production.execute!(success: true) }.to change(production, :success_count).by(1)
    end

    it 'does not increment success count on failure' do
      expect { production.execute!(success: false) }.not_to change(production, :success_count)
    end
  end

  describe '#success_rate' do
    it 'returns 0.0 when no executions' do
      expect(production.success_rate).to eq(0.0)
    end

    it 'computes success ratio' do
      3.times { production.execute!(success: true) }
      production.execute!(success: false)
      expect(production.success_rate).to eq(0.75)
    end
  end

  describe '#reliable?' do
    it 'returns false initially' do
      expect(production).not_to be_reliable
    end

    it 'returns true after sufficient successful executions' do
      5.times { production.execute!(success: true) }
      expect(production).to be_reliable
    end
  end

  describe '#to_h' do
    it 'returns hash representation' do
      hash = production.to_h
      expect(hash).to include(:id, :condition, :action, :domain, :success_rate, :reliable)
    end
  end
end
