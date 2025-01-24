require_relative '../../automated_init'

context "Output" do
  context "Comment" do
    context "Block" do
      context "Single Comment" do
        text = "Some comment"
        inner_text = "Some inner comment"

        commented = Controls::Events::Commented.example(text:)
        block_started = Controls::Events::CommentBlockStarted.example
        inner_commented = Controls::Events::Commented.example(text: inner_text)
        block_finished = Controls::Events::CommentBlockFinished.example

        output = Controls::Output.example

        context "Handle Commented Events" do
          output.handle(commented)
          output.handle(block_started)
          output.handle(inner_commented)
          output.handle(block_finished)

          context "Written Text" do
            writer = output.writer
            written_text = writer.written_text

            control_text = <<~TEXT
            Some comment
              Some inner comment
            TEXT

            comment written_text
            detail "Control:", control_text

            test do
              assert(writer.written?(control_text))
            end
          end
        end
      end

      context "Mixed Comment and Detail" do
        text = "Some comment"
        inner_text = "Some inner comment"
        inner_detail = "Some inner detail"

        commented = Controls::Events::Commented.example(text:)
        block_started = Controls::Events::CommentBlockStarted.example
        inner_commented = Controls::Events::Commented.example(text: inner_text)
        inner_detailed = Controls::Events::Detailed.example(text: inner_detail)
        block_finished = Controls::Events::CommentBlockFinished.example

        output = Controls::Output.example

        context "Handle Events" do
          output.handle(commented)
          output.handle(block_started)
          output.handle(inner_commented)
          output.handle(inner_detailed)
          output.handle(block_finished)

          context "Written Text" do
            writer = output.writer
            written_text = writer.written_text

            control_text = <<~TEXT
            Some comment
              Some inner comment
              Some inner detail
            TEXT

            comment written_text
            detail "Control:", control_text

            test do
              assert(writer.written?(control_text))
            end
          end
        end
      end

      context "Nested Blocks" do
        text = "Some comment"
        inner_text = "Some inner comment"
        deepest_text = "Some deepest comment"

        commented = Controls::Events::Commented.example(text:)
        block_started = Controls::Events::CommentBlockStarted.example
        inner_commented = Controls::Events::Commented.example(text: inner_text)
        inner_block_started = Controls::Events::CommentBlockStarted.example
        deepest_commented = Controls::Events::Commented.example(text: deepest_text)
        inner_block_finished = Controls::Events::CommentBlockFinished.example
        block_finished = Controls::Events::CommentBlockFinished.example

        output = Controls::Output.example

        context "Handle Events" do
          output.handle(commented)
          output.handle(block_started)
          output.handle(inner_commented)
          output.handle(inner_block_started)
          output.handle(deepest_commented)
          output.handle(inner_block_finished)
          output.handle(block_finished)

          context "Written Text" do
            writer = output.writer
            written_text = writer.written_text

            control_text = <<~TEXT
            Some comment
              Some inner comment
                Some deepest comment
            TEXT

            comment written_text
            detail "Control:", control_text

            test do
              assert(writer.written?(control_text))
            end
          end
        end
      end
    end
  end
end
