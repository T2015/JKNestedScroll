struct JKNestedScroll {
    var text = "Hello, World!"
}




import UIKit


extension UIScrollView: UIGestureRecognizerDelegate {
    
    struct JKPropertyKey {
        static var shouldRecognizeSimultaneously = "shouldRecognizeSimultaneously"
        static var lockOffset = "lockOffset"
        static var lastOffset = "lastOffset"
        
        
        static var subScrollView = "subScrollView"
        static var canScrollHeaderHeight = "canScrollHeaderHeight"
        
        
    }
    
    enum ScrollingDirection {
        case none, top, bottom
    }
    
    
    open var shouldRecognizeSimultaneously: Bool {
        set{
            let value = newValue ? "" : nil
            objc_setAssociatedObject(self, &JKPropertyKey.shouldRecognizeSimultaneously, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            guard let _ = objc_getAssociatedObject(self, &JKPropertyKey.shouldRecognizeSimultaneously) else { return false }
            return true
        }
    }
    
    
    /// 是否锁定
    var lockOffset: Bool {
        set{
            let value = newValue ? "" : nil
            objc_setAssociatedObject(self, &JKPropertyKey.lockOffset, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            guard let _ = objc_getAssociatedObject(self, &JKPropertyKey.lockOffset) else { return false }
            return true
        }
    }
    
    
    /// 最后的位置
    var lastOffset: CGPoint {
        set{
            let value = NSValue.init(cgPoint: newValue)
            objc_setAssociatedObject(self, &JKPropertyKey.lastOffset, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            guard let result = objc_getAssociatedObject(self, &JKPropertyKey.lastOffset) as? NSValue else { return CGPoint.zero }
            return result.cgPointValue
        }
    }
    
    /// 滚动方向
    var scrollingDirection: ScrollingDirection {
        
        var dir = ScrollingDirection.none
        
        if self.contentOffset.y > lastOffset.y {
            dir = .top
        }
        if self.contentOffset.y < lastOffset.y {
            dir = .bottom
        }
        return dir
    }
    
    
    /// 子滚动视图
    open var subScrollView: UIScrollView? {
        set{
            objc_setAssociatedObject(self, &JKPropertyKey.subScrollView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self, &JKPropertyKey.subScrollView) as? UIScrollView
        }
    }
    
    
    /// 顶部可滚动高度
    var canScrollHeaderHeight: CGFloat {
        set{
            let value = NSNumber(value: Int(newValue))
            objc_setAssociatedObject(self, JKPropertyKey.canScrollHeaderHeight, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            guard let result = objc_getAssociatedObject(self, JKPropertyKey.canScrollHeaderHeight) as? NSNumber else {
                return 0
            }
            return CGFloat(result.intValue)
        }
    }
    
    
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.shouldRecognizeSimultaneously
    }
    
}




extension UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let nest = scrollView
        guard let subScroll = nest.subScrollView else {
            subScrollViewDidScroll(scrollView)
            nestScrollViewDidScroll(scrollView)
            return
        }
        
        
        let point = nest.contentOffset
        let subPoint = subScroll.contentOffset
        
        
        if point.y > nest.canScrollHeaderHeight {
            nest.lockOffset = true
            nest.lastOffset = CGPoint(x: 0, y: nest.canScrollHeaderHeight)
            subScroll.lockOffset = false
        }else if nest.scrollingDirection == .top {
            nest.lockOffset = false
            subScroll.lockOffset = true
        }
        
        if point.y < 0 {
            nest.lockOffset = true
            nest.lastOffset = CGPoint.zero
            subScroll.lockOffset = false
        }else if nest.scrollingDirection == .bottom {
            
            if subPoint.y > 0 {
                nest.lockOffset = true
                subScroll.lockOffset = false
            }else{
                nest.lockOffset = false
                subScroll.lockOffset = true
            }
        }
        
        
        subScrollViewDidScroll(nest)
    }
    
    
    func nestScrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    
    func subScrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.lockOffset == false {
            scrollView.lastOffset = scrollView.contentOffset
        }
        scrollView.contentOffset = scrollView.lastOffset
    }
    
}


