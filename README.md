ResizableView
=============

Sample iOS app that shows a simple view that can be sized, scaled and moved by touches.

I'm no fan of samples that are jammed full of code that obscures the main area of interest and so this example attempts to limit itself to code that shows resizing and scaling. This sample is a prototype for project work where I want to see how to put up a view that the user could resize and move at will. The project idea is to show a collage of pictures and allow the user to place and resize the images at will, so this was proof that it was not too complicated.

The approach taken here is to drop a view on the main view and have the containing view controller do all of the work for the view. This approach is perhaps not the optimal solution for a real app, but this is sufficient for a prototype to demonstrate the concept. In a real collage app there may be many views will have to managed so something more sophisticated will be required. One approach would be to use UIViews for each item and when a view is selected for manipulation, a special view like the target view here, takes on the characteristics of the view it wants to manipulate then hides the old view. When the manipulations are finished, the old view is repositioned and the target view goes away.

The target view here, the ResizableFrameView, is drawn with a border showing the area where the edges can be dragged. Panning on the sides will grow or shrink a single edge, and corners will do the same for two adjacent edges. Pinching to scale the view is also supported, but the amount of resizing is a guess. UIScrollView has a nice feel when resizing content, so determining how that is accomplished would be a nice refinement to replace the simple "proportion to scale" taken here.
