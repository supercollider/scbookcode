// figure 12.1

(
w = Window("empty window", Rect(50, 100, 400, 300));
w.front;
)

w.alwaysOnTop_(true);

w.visible_(false);

w.isClosed; // returns false; invisible ≠ closed

w.visible_(true);

w.close;

w.visible_(true); // no effect after closing

w.isClosed; // returns true