# This class takes an array of records and a Proc (which can be any block of
# code) as input, and the process method applies the Proc on each record in the
# array. The precondition block is passed to the BatchOperation class and
# executed before the operation is performed. If the precondition check fails,
# the record is added to the failure list, otherwise, the operation is executed
# and the result (success or failure) is recorded accordingly.
class BatchOperation
  def initialize(records, operation, precondition: nil)
    @records = records
    @operation = operation
    @precondition = precondition
  end

  def process
    success = []
    failure = []
    @records.each do |record|
      if !@precondition || @precondition.call(record)
        begin
          @operation.call(record)
          success << record
        rescue StandardError
          failure << record
        end
      else
        failure << record
      end
    end

    [success, failure]
  end
end
