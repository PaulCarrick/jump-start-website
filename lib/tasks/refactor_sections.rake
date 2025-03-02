# lib/tasks/html.rake

namespace :sections do
  desc "Convert sections to cells."
  task :convert, [ :verbose, :interactive, :debug ] => :environment do |_, args|
    args.with_defaults(verbose: false, interactive: false, debug: false)

    # Invoke subtasks with the interactive argument
    Rake::Task["sections:generate_cells"].invoke(args[:verbose], args[:interactive], args[:debug])

    puts "Finished Converting Sections to Cells."
  end

  desc "Generate cells from sections"
  task :generate_cells, [ :verbose, :interactive, :debug ] => :environment do |_, args|
    args.with_defaults(verbose: false, interactive: false, debug: false)

    verbose = args[:verbose] == "true"

    puts "Generating cells from sections: #{args[:verbose]}"

    ActiveRecord::Base.transaction do
      debugger if args[:debug] == "true"

      Cell.delete_all

      ActiveRecord::Base.connection.execute("ALTER SEQUENCE cells_id_seq RESTART WITH 1")

      Section.find_each(batch_size: 1000) do |section|
        puts "Generating cells for section: #{section.section_name}..." if verbose
        section.generate_cells

        if section.errors.present?
          identifier = "(#{section.id} - #{section.content_type} #{section.section_order})"

          display_errors(section.errors, section, identifier, section.description, section.formatting)

          # Call prompt only if interactive mode is enabled
          prompt if args[:interactive]

          raise ActiveRecord::Rollback
        end

        puts "Successfully generated cells for section: #{section.section_name}." if verbose && !section.errors.present?
      end
    end

    def display_errors(errors, object, identifier, html, json = nil)
      errors.each do |error|
        display_error(error, object, identifier, html, json)
      end
    end

    def display_error(error, object, identifier, html, json = nil)
      error_message = object.errors.full_messages.join(', ')
      error_message = error.message unless error_message.present?
      puts "Can't save #{object.class.name}: #{identifier}, Error: #{error_message}"
      puts json if json.present?
      puts Utilities.pretty_print_html(html)
    end

    def prompt(message = "Press enter to continue...")
      print "#{message}: " # Display the prompt message
      STDIN.gets.chomp # Explicitly read from STDIN to capture input
    end
  end
end
