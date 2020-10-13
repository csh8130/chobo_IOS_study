//
//  TutorialMasterVC.swift
//  MyMemory
//
//  Created by Choi SeungHyuk on 2020/10/13.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class TutorialMasterVC: UIViewController {
    var pageVC: UIPageViewController!
    
    var contentTitles = ["STEP 1", "STEP 2", "STEP 3", "STEP 4"]
    var contentImages = ["Page0", "Page1", "Page2", "Page3"]
    
    func getContentVC(atIndex idx: Int) -> UIViewController? {
        guard self.contentTitles.count >= idx && self.contentTitles.count > 0 else {
            return nil
        }
        
        guard let cvc = self.instanceTutorialVC(name: "ContentsVC") as? TutorialContentsVC else {
            return nil
        }
        cvc.titleText = self.contentTitles[idx]
        cvc.imageFile = self.contentImages[idx]
        cvc.pageIndex = idx
        return cvc
    }
}
