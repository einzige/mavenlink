require "spec_helper"

describe Mavenlink::StoryStateChange, type: :model do
  describe "associations" do
    it { is_expected.to respond_to :user }
    it { is_expected.to respond_to :story }
  end
end
