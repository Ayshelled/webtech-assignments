# The listing description and house rules become rich text (Action Text). The plain
# text already saved is copied into action_text_rich_texts as HTML, one <p> per
# paragraph, and the old columns are removed so there is a single source of truth.
class MoveListingTextsToActionText < ActiveRecord::Migration[8.1]
  RICH_TEXT_COLUMNS = %w[description house_rules].freeze

  def up
    select_rows("SELECT id, description, house_rules FROM listings").each do |id, *texts|
      RICH_TEXT_COLUMNS.zip(texts).each do |name, text|
        next if text.blank?

        execute <<~SQL.squish
          INSERT INTO action_text_rich_texts (name, body, record_type, record_id, created_at, updated_at)
          VALUES (#{quote(name)}, #{quote(to_html(text))}, 'Listing', #{id.to_i}, NOW(), NOW())
        SQL
      end
    end

    remove_column :listings, :description
    remove_column :listings, :house_rules
  end

  def down
    add_column :listings, :description, :text
    add_column :listings, :house_rules, :text

    RICH_TEXT_COLUMNS.each do |name|
      execute <<~SQL.squish
        UPDATE listings SET #{name} = rich.body
        FROM action_text_rich_texts rich
        WHERE rich.record_type = 'Listing' AND rich.record_id = listings.id AND rich.name = #{quote(name)}
      SQL
    end
    execute "UPDATE listings SET description = '' WHERE description IS NULL"
    change_column_null :listings, :description, false
    execute "DELETE FROM action_text_rich_texts WHERE record_type = 'Listing'"
  end

  private

  def quote(value)
    connection.quote(value)
  end

  # Paragraphs separated by a blank line become <p>; single line breaks become <br>
  def to_html(text)
    text.strip.split(/\n{2,}/).map { |paragraph|
      "<p>#{ERB::Util.html_escape(paragraph).gsub("\n", "<br>")}</p>"
    }.join
  end
end
