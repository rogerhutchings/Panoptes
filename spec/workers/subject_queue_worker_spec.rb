require "spec_helper"

RSpec.describe SubjectQueueWorker do
  subject { described_class.new }
  let(:workflow) { create(:workflow_with_subject_set) }

  describe "#perform" do

    before(:each) do
      available_smss = (1..100).to_a
      allow_any_instance_of(PostgresqlSelection).to receive(:select).and_return(available_smss)
    end

    context "with no user or set" do
      it 'should create a subject queue with the default number of items' do
        subject.perform(workflow.id)
        queue = SubjectQueue.find_by(workflow: workflow)
        expect(queue.set_member_subject_ids.length).to eq(100)
      end
    end

    context "when a workflow id string is passed in" do
      it "should not raise an error" do
        expect{subject.perform(workflow.id.to_s)}.to_not raise_error
      end
    end

    context "when the workflow does not exist" do
      it 'should not raise an error' do
        expect do
          subject.perform(-1)
        end.to_not raise_error
      end
    end

    describe "#load_subjects" do
      context "when there are selected subjects to queue" do
        it 'should attempt to queue an empty set' do
          allow_any_instance_of(PostgresqlSelection).to receive(:select).and_return([1])
          expect(SubjectQueue).to receive(:enqueue)
          subject.perform(workflow.id)
        end
      end

      context "when there are no selected subjects to queue" do

        it 'should not attempt to queue an empty set' do
          allow_any_instance_of(PostgresqlSelection).to receive(:select).and_return([])
          expect(SubjectQueue).to_not receive(:enqueue)
          subject.perform(workflow.id)
        end
      end
    end
  end
end
