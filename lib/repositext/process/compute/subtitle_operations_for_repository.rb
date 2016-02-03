class Repositext
  class Process
    class Compute

      # Computes subtitle operations for an entire repository. Going from
      # git commit `fromGitCommit` to git commit `toGitCommit`.
      class SubtitleOperationsForRepository

        # Initializes a new instance from high level objects.
        # @param repository [Repositext::Repository::Content]
        # @param fromGitCommit [String]
        # @param toGitCommit [String]
        def initialize(repository, fromGitCommit, toGitCommit)
          @repository = repository
          @fromGitCommit = fromGitCommit
          @toGitCommit = toGitCommit
        end

        # @return [Repositext::Subtitle::OperationsForRepository]
        def compute
          diff = @repository.diff(@fromGitCommit, @toGitCommit, context_lines: 0)
          operations_for_all_files = diff.patches.map { |patch|
            file_name = patch.delta.old_file[:path]
next nil  unless file_name =~ /\/eng64-0212/
            # Skip non content_at files
            next nil  unless file_name =~ /\Acontent\/.+\d{4}\.at\z/
            file_path = File.join(@repository.base_dir, file_name)
            content_at_file = Repositext::RFile::Text.new(
              File.read(file_path),
              @repository.language,
              file_path,
              @repository
            )
            SubtitleOperationsForFile.new_from_content_at_file_and_patch(
              content_at_file,
              patch
            ).compute
          }.compact

          Repositext::Subtitle::OperationsForRepository.new(
            {
              repository: @repository.name,
              fromGitCommit: @fromGitCommit,
              toGitCommit: @toGitCommit,
            },
            operations_for_all_files
          )
        end

      end

    end
  end
end
