//
//  SlideShowViewController.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/8/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  Learned how to do UIPageViewController by reading the example at:
//  https://github.com/UnicornTV/Swift-Example-UIPageViewController/blob/master/Swift%20Pages/ViewController.swift
//  Some of the code from this example was adapted to this program
//
//  Adapted code for NSTimer from this site:
//  http://stackoverflow.com/questions/29358685/set-timer-to-uipageviewcontroller
//
//  This class represents a UIViewController that is repurposed into
//  an UIPageViewController that supports a slideshow of available friends
//  that can be navigated through swiping or through automatic scrolling
//  coordinated by an NSTimer object

import UIKit

class SlideShowViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    // MARK: Public API
    var pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    
    var availableContacts: [Contact]? = nil
    
    // Function programatically moves the pageViewController forward by 1
    // page if we have more than 1 content page
    func moveToNextPage() {
        if availableContacts != nil && availableContacts?.count != 0{
            if let firstController = createNewContentViewController((currentContentIndex+1) % availableContacts!.count) {
                currentContentIndex++
                pageViewController.setViewControllers([firstController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Private API
    private var timer: NSTimer = NSTimer()
    private var currentContentIndex: Int = 0
    
    // Function sets up our pageViewController
    private func setupPageViewController() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
        if let startingViewController: SlideShowPageContentViewController = createNewContentViewController(currentContentIndex) {
            let allViewControllers = [startingViewController]
            pageViewController.setViewControllers(allViewControllers as [UIViewController], direction: .Forward, animated: true, completion: nil)
            addChildViewController(pageViewController)
            view.addSubview(pageViewController.view)
            pageViewController.didMoveToParentViewController(self)
        }
    }
    
    // Function creates a new content page and returns that page
    // to the caller
    private func createNewContentViewController(index: Int) -> SlideShowPageContentViewController? {
        if availableContacts != nil && (availableContacts!.count > 0 || availableContacts!.count < index) {
            let contentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SlideShowPageContent") as! SlideShowPageContentViewController
            contentViewController.imageContent = UIImage(data: availableContacts![index].photo!)
            contentViewController.textContent = availableContacts![index].firstName! + " " + availableContacts![index].lastName!
            contentViewController.index = index
            return contentViewController
        } else {
            return nil
        }
    }
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupPageViewController()
        if availableContacts?.count > 1 {
            timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("moveToNextPage"), userInfo: nil, repeats: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! SlideShowPageContentViewController).index
        if index == 0 {
            return nil
        }
        index--
        return createNewContentViewController(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! SlideShowPageContentViewController).index
        index++
        if index == self.availableContacts!.count {
            return nil
        }
        return createNewContentViewController(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        if availableContacts != nil {
            return availableContacts!.count
        }
        else {
            return 0
        }
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    // MARK: UIPageViewControllerDelegate
    // Function tells us when a page was moved forward or backwards by
    // the user so that the program can reset the time and update the
    // current auto scroller accordingly
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            timer.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("moveToNextPage"), userInfo: nil, repeats: true)
            let prevIndex = (previousViewControllers[0] as! SlideShowPageContentViewController).index
            let currentIndex = (pageViewController.viewControllers![0] as! SlideShowPageContentViewController).index
            if currentIndex > prevIndex {
                currentContentIndex++
            }
            else {
                currentContentIndex--
            }
        }
    }

}
