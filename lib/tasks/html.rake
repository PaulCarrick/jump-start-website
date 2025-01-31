# lib/tasks/html.rake

namespace :html do
  desc "Cleanup HTML"
  task :clean, [ :interactive ] => :environment do |t, args|
    args.with_defaults(interactive: false)

    # Invoke subtasks with the interactive argument
    Rake::Task["html:cleanup_sections_html"].invoke(args[:interactive])
    Rake::Task["html:cleanup_blogs_html"].invoke(args[:interactive])
    Rake::Task["html:cleanup_comments_html"].invoke(args[:interactive])
    Rake::Task["html:cleanup_image_file_html"].invoke(args[:interactive])

    puts "Finished Cleaning HTML"
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

  desc "Cleanup Sections HTML"
  task :cleanup_sections_html, [ :interactive ] => :environment do |t, args|
    args.with_defaults(interactive: false)
    puts "Cleaning Sections with interactive mode: #{args[:interactive]}"

    Thread.current[:skip_checksum_verification] = true

    Section.find_each(batch_size: 1000) do |section|
      begin
        if section.description.present?
          section.description = Utilities.pretty_print_html(section.description)
        end

        section.save!
      rescue => e
        identifier = "(#{section.id} - #{section.content_type} #{section.section_order})"

        display_error(e, section, identifier, section.description, section.formatting)

        # Call prompt only if interactive mode is enabled
        prompt if args[:interactive]
      end
    end
  end

  desc "Cleanup Blogs HTML"
  task :cleanup_blogs_html, [ :interactive ] => :environment do |t, args|
    args.with_defaults(interactive: false)
    puts "Cleaning Blogs with interactive mode: #{args[:interactive]}"

    Thread.current[:skip_checksum_verification] = true

    BlogPost.find_each(batch_size: 1000) do |blog|
      begin
        if blog.content.present?
          blog.content = Utilities.pretty_print_html(blog.content)
        end

        blog.save!
      rescue => e
        identifier = "(#{blog.id} - #{blog.title})"

        display_error(e, blog, identifier, blog.content)

        prompt if args[:interactive]
      end
    end
  end

  desc "Cleanup Post Comments HTML"
  task :cleanup_comments_html, [ :interactive ] => :environment do |t, args|
    args.with_defaults(interactive: false)
    puts "Cleaning Comments with interactive mode: #{args[:interactive]}"

    Thread.current[:skip_checksum_verification] = true

    PostComment.find_each(batch_size: 1000) do |comment|
      begin
        if comment.content.present?
          comment.content = Utilities.pretty_print_html(comment.content)
        end

        comment.save!
      rescue => e
        identifier = "(#{comment.id} - #{comment.title})"
        display_error(e, comment, identifier, comment.content)

        # Call prompt only if interactive mode is enabled
        prompt if args[:interactive]
      end
    end
  end

  desc "Cleanup Image File HTML"
  task :cleanup_image_file_html, [ :interactive ] => :environment do |t, args|
    args.with_defaults(interactive: false)
    puts "Cleaning Image Files with interactive mode: #{args[:interactive]}"

    Thread.current[:skip_checksum_verification] = true

    ImageFile.skip_callback(:find, :after, :verify_checksum)

    ImageFile.find_each(batch_size: 1000) do |image_file|
      begin
        if image_file.description.present?
          image_file.description = Utilities.pretty_print_html(image_file.description)
        end

        image_file.save!
      rescue => e
        identifier = "(#{image_file.id} - #{image_file.name})"

        display_error(e, image_file, identifier, image_file.description)

        prompt if args[:interactive]
      end
    end

    ImageFile.set_callback(:find, :after, :verify_checksum)
  end
end
