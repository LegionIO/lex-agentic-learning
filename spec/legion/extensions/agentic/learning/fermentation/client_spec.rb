# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Fermentation::Client do
  subject(:client) { described_class.new }

  it 'responds to runner methods' do
    expect(client).to respond_to(:create_substrate, :ferment, :catalyze, :fermentation_status)
  end

  it 'runs a full fermentation lifecycle' do
    result = client.create_substrate(substrate_type: :raw_idea, domain: :cognitive, content: 'test')
    sub_id = result[:substrate][:id]

    client.catalyze(substrate_id: sub_id, catalyst_type: :analogy)
    10.times { client.ferment(substrate_id: sub_id) }

    status = client.fermentation_status
    expect(status[:total_substrates]).to eq(1)
    expect(status[:success]).to be true
  end

  it 'lists ripe substrates' do
    result = client.create_substrate(substrate_type: :raw_idea, domain: :cognitive, potency: 0.8)
    sub_id = result[:substrate][:id]
    15.times { client.ferment(substrate_id: sub_id, rate: 0.05) }
    ripe = client.list_ripe
    expect(ripe[:success]).to be true
  end

  it 'ferments all substrates' do
    client.create_substrate(substrate_type: :raw_idea, domain: :cognitive)
    client.create_substrate(substrate_type: :raw_idea, domain: :emotional)
    result = client.ferment_all
    expect(result[:success]).to be true
  end
end
