//
//  CommentCell.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 17/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var commentBox: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var comment: Comment!
    
    func configureCell(comment: Comment) {
        self.comment = comment
        self.dateLbl.text = comment.date
        self.usernameLbl.text = comment.commentAuthorUsername
        self.commentBox.text = comment.comment
    }

}
