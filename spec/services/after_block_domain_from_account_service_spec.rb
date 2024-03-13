# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AfterBlockDomainFromAccountService do
  subject { described_class.new }

  let!(:wolf) { Fabricate(:account, username: 'wolf', domain: 'evil.org', inbox_url: 'https://evil.org/inbox', protocol: :activitypub) }
  let!(:alice) { Fabricate(:account, username: 'alice') }

  before do
    wolf.follow!(alice)
  end

  it 'purge followers from blocked domain and sends `Reject->Follow` accordingly' do
    expect { subject.call(alice, 'evil.org') }
      .to change { wolf.following?(alice) }.from(true).to(false)

    expect(ActivityPub::DeliveryWorker).to have_enqueued_sidekiq_job(/Reject/, alice.id, wolf.inbox_url)
  end
end
