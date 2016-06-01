f= imageScroller();
data = guihandles(f);
data.diagList = structByDiagnosis{1};
data.idx = 50;
data.pointsOfInterest = {};

guidata(f,data);
