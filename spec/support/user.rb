RSpec.shared_context 'logged as admin' do
  let(:user) { User.anonymous }
  before do
    [:logged?, :admin?, :allowed_to?].each do |m|
      allow(user).to receive(m).and_return true
    end
    allow(User).to receive(:current).and_return user
  end
end

RSpec.shared_context 'logged as' do
  let(:user) { User.anonymous }
  before do
    [:logged?].each do |m|
      allow(user).to receive(m).and_return true
    end
    allow(User).to receive(:current).and_return user
    allow(user).to receive(:allowed_to?) {|action, context=nil, options= {}| Role.non_member.allowed_to?(action) }
  end
end