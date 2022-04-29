require "rails_helper"

RSpec.describe ApplicationJob, type: :job do
  describe ".perform_unique_later" do
    let(:job_args) { [{ test: true }, "args", 1] }
    subject { ApplicationJob.perform_unique_later(*job_args) }

    context "queue is empty" do
      before { stub_queue([]) }

      it "enqueues the job" do
        expect(ApplicationJob).to receive(:perform_later).with(*job_args)
        subject
      end
    end

    context "identical job does not exist in the queue" do
      before { stub_queue([{ other_job: true }]) }

      it "enqueues the job" do
        expect(ApplicationJob).to receive(:perform_later).with(*job_args)
        subject
      end
    end

    context "identical job exists in the queue" do
      before { stub_queue([job_args]) }

      it "does not enqueue the job" do
        expect(ApplicationJob).not_to receive(:perform_later)
        subject
      end

      it "returns false" do
        expect(subject).to eq false
      end
    end

    context "identical job exists in the queue as a second argument set" do
      before { stub_queue([[{ first_args: true }], job_args]) }

      it "does not enqueue the job" do
        expect(ApplicationJob).not_to receive(:perform_later)
        subject
      end

      it "returns false" do
        expect(subject).to eq false
      end
    end

    context "job with identical args exists, but with a different job class" do
      before { stub_queue([job_args], job_class: "MyTestJob") }

      it "enqueues the job" do
        expect(ApplicationJob).to receive(:perform_later).with(*job_args)
        subject
      end
    end

    private

    def stub_queue(arguments, job_class: "ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper")
      serialized_args = arguments.map { |a| ActiveJob::Arguments.serialize(a) }
      fake_queue = [OpenStruct.new(item: { # rubocop:disable Style/OpenStructUse
                                     "class" => job_class,
                                     "args" => serialized_args.map { |a| { "arguments" => a } } })]
      allow(Sidekiq::Queue).to receive(:new).and_return(fake_queue)
    end
  end
end
