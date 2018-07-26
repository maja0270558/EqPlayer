import UIKit

class EQSaveProjectPageAddTrackHeader: UIView {
    var addTrack: () -> Void = {}
    @IBAction func addAction(_: UIButton) {
        addTrack()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
    }
}
