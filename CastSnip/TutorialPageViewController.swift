//
//  TutorialPageViewController.swift
//  CastSnip
//
//  Created by ewuehler on 3/9/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        view.backgroundColor = Theme.shared.purple()
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newStepViewController("One"), self.newStepViewController("Two"),
            self.newStepViewController("Three"), self.newStepViewController("Four"),
            self.newStepViewController("Five"), self.newStepViewController("Six")]
    }()
    
    private func newStepViewController(_ step: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) . instantiateViewController(withIdentifier:"Tutorial\(step)")
    }
    

}

extension TutorialPageViewController: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.firstIndex(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            // If we get to the end of the tutorial, hide it
            Select.setting.tutorial(hide: true)
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    
}


