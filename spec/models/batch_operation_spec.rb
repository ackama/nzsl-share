require "spec_helper"
require_relative "../../app/models/batch_operation"

RSpec.describe BatchOperation do
  let(:records) { [1, 2, 3, 4, 5] }
  let(:operation) { proc { |record| "Processing record: #{record}" } }
  let(:precondition) { proc { |record| record.even? } }
  let(:batch_operation) { BatchOperation.new(records, operation, precondition:) }

  describe "#process" do
    it "returns a tuple of successful records and failed records" do
      success, failure = batch_operation.process

      expect(success).to match_array([2, 4])
      expect(failure).to match_array([1, 3, 5])
    end

    context "when precondition is not provided" do
      let(:batch_operation) { BatchOperation.new(records, operation) }

      it "processes all records" do
        success, failure = batch_operation.process

        expect(success).to match_array(records)
        expect(failure).to be_empty
      end
    end
  end
end
