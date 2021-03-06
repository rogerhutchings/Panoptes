module Translatable
  extend ActiveSupport::Concern

  included do
    validates :primary_language, format: {with: /\A[a-z]{2}(\z|-[A-z]{2})/}
    has_many content_association, autosave: true, inverse_of: name.downcase.to_sym
    can_be_linked content_model.name.underscore.to_sym, :scope_for, :translate, :user

    validates content_association, presence: true
  end

  module ClassMethods
    def content_association
      "#{model_name.singular}_contents".to_sym
    end

    def content_model
      "#{name}Content".constantize
    end

    def load_with_languages(query, languages=nil)
      where_clause = "#{content_association}.language = #{table_name}.primary_language"
      query = query.joins(content_association).eager_load(content_association)

      if languages
        where_clause = "#{where_clause} OR #{content_association}.language ~ ?"
        query.where(where_clause, lang_regex(languages))
      else
        query.where(where_clause)
      end
    end

    private

    def lang_regex(langs)
      langs = langs.map{ |lang| lang[0..1] }.uniq.join("|")
      "^(#{langs}).*"
    end
  end

  def content_for(languages)
    content = nil
    languages = Array.wrap(languages).flat_map do |lang|
      lang.length == 2 ? lang : [lang, lang[0..1]]
    end.uniq

    languages.each do |lang|
      content = content_association.to_a.find{ |c| c.language == lang }
      if lang.length == 2 && !content
        content = content_association.to_a.find do |c|
          c.language =~ /^#{lang[0..1]}.*/ 
        end
      end

      break if content
    end
    content = primary_content unless content
    return content
  end

  def available_languages
    content_association.select('language').map(&:language).map(&:downcase)
  end

  def content_association
    @content_association ||= send(self.class.content_association)
  end

  def primary_content
    @primary_content ||= if content_association.loaded?
                           content_association.to_a.find do |content|
                             content.language == primary_language
                           end
                         else
                           content_association.where(language: primary_language).first
                         end
  end
end
