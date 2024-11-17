require 'spreadsheet'

class PostExcelExportService
  attr_reader :posts

  def initialize(posts)
    @posts = posts
  end

  def export_to_excel
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet(name: 'Posts')

    headers = ['Регион', 'Заголовок', 'Текст поста', 'Автор', 'Файлы', 'Дата размещения']
    sheet.row(0).concat headers

    posts.each_with_index do |post, index|
      sheet.row(index + 1).replace [
        post.region.name,
        post.title,
        post.body,
        post.user.fio,
        format_files(post.files),
        post.created_at.strftime('%d.%m.%Y')
      ]
    end

    excel_data = StringIO.new
    book.write(excel_data)
    excel_data.string
  end

  private

  def format_files(files)
    files.map do |file|
      Rails.application.routes.url_helpers.url_for(file)
    end.join("\n")
  end
end
