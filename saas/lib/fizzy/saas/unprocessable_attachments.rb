module Fizzy
  module Saas
    # A permanent verdict on one variant must not fail the save that attached the file: immediate variants
    # transform inside the record's after_commit, so a raise there 500s a POST that succeeded. There are
    # two immediate paths, and only one is a job — a direct-uploaded embed runs under
    # `CreateVariantsJob.perform_now`, which `discard_on` catches, while a form-uploaded io is varied
    # before the blob is stored, so a rescue catches it there. Neither catches the transient class, which
    # the client gem already retries. Both catches report, because they are where the raise stops;
    # everywhere else it reaches Sentry on its own.
    module UnprocessableAttachments
      # Rails' own loop, with the rescue inside it rather than around it: one variant failing must not skip
      # the rest, and the loop's last line marks the variants as processed — miss it and Rails re-runs every
      # one of them as a job after commit.
      module Attachment
        private
          def process_immediate_variants_from_io(io)
            return unless blob.variable?

            named_variants.each do |_variant_name, named_variant|
              next unless named_variant.process(record) == :immediately

              begin
                blob.variant(named_variant.transformations).process_from_io(io)
              rescue Cell::UnprocessableAttachment => error
                Rails.error.report error, handled: true, severity: :info
              end
              io.rewind if io.respond_to?(:rewind)
            end

            self.immediate_variants_processed = true
          end
      end

      def self.install!
        ActiveSupport.on_load(:active_storage_attachment) { prepend Attachment }

        %w[ ActiveStorage::CreateVariantsJob ActiveStorage::TransformJob ].each do |job|
          job.constantize.discard_on Cell::UnprocessableAttachment, report: true
        end
      end
    end
  end
end
