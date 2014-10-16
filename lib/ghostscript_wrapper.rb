class GhostscriptWrapper
  def self.merge_pdf_files(files)
    # A tempfile to store merged output:
    out_file = Tempfile.new("merged_pdf")

    # "Re-distill" all our input PDFs before attempting to merge.
    # This cleans up a number of potential non-comformities in the individual PDFs that could
    # flub up the final merge.  (In Oct 2014, eg, we were seeing dropped/mangled characters in the merge)
    redistilled_files = []
    files.each do |file|
      redistilled_file = Tempfile.new("redistilled")
      redistilled_files << redistilled_file
      ghostscript_redistill_pdf infile_path: file.path, outfile_path: redistilled_file.path
    end

    infile_paths = redistilled_files.map do |file| file.path end

    # Merge 
    ghostscript_merge_pdfs infile_paths: infile_paths, outfile_path: out_file.path

    # Read merged PDF content from the temp file:
    pdf = out_file.read

    # Remove output temp file:
    out_file.unlink

    # Remove the redistilled files
    redistilled_files.each do |file|
      file.unlink
    end

    return pdf
  end

  def self.ghostscript_redistill_pdf(infile_path:, outfile_path:)
    cmd = "gs -o #{outfile_path} -sDEVICE=pdfwrite #{infile_path} 2>&1"
    output = `#{cmd}`
  end

  def self.ghostscript_merge_pdfs(infile_paths:, outfile_path:)
    cmd = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=#{outfile_path} #{infile_paths.join(" ")} 2>&1"
    output = `#{cmd}`
  end
end
