require "rails_helper"

RSpec.describe CommentReport, type: :model do
  subject { FactoryBot.build(:comment_report) }

  it { is_expected.to be_valid }

  it "is invalid without a user" do
    subject.user = nil
    expect(subject).not_to be_valid
  end

  it "is invalid without a comment" do
    subject.comment = nil
    expect(subject).not_to be_valid
  end

  it "is valid without a resolving user" do
    subject.resolved_by = nil
    expect(subject).to be_valid
  end
end
