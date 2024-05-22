//@Grab('org.apache.pdfbox:pdfbox:2.0.27')
import org.apache.pdfbox.pdmodel.PDDocument
import org.apache.pdfbox.text.PDFTextStripper

def readPdfText(String filePath) {
    try {
        PDDocument document = PDDocument.load(new File(filePath))
        PDFTextStripper stripper = new PDFTextStripper()
        String text = stripper.getText(document)
        document.close()
        return text
    } catch (Exception e) {
        e.printStackTrace()
        return null
    }
}

// Example usage
def filePath = '/Users/sanjeev/workspace/scratchpad/pdf-sample.pdf'
def pdfText = readPdfText(filePath)
println(pdfText)

//  groovy -cp .:pdf_jars/pdfbox-2.0.29.jar:pdf_jars/fontbox-2.0.29.jar:pdf_jars/commons-logging-1.2.jar test.groovy