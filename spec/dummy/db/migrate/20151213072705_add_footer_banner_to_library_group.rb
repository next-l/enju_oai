class AddFooterBannerToLibraryGroup < ActiveRecord::Migration[4.2]
  def up
    LibraryGroup.add_translation_fields! footer_banner: :text
  end

  def down
    remove_column :library_group_translations, :footer_banner
  end
end
