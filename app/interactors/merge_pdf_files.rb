class MergePdfFiles
  include Interactor

  def perform
    require_in_context(:files)
    pdf = GhostscriptWrapper.merge_pdf_files(files)
    files.each do |file| 
      file.unlink 
    end
    context[:pdf] = pdf
  end
end
