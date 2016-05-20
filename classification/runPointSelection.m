f= imageScroller();
data = guihandles(f);
data.diagList = structByDiagnosis{2};
data.idx = 0;
data.pointsOfInterest = {};

guidata(f,data);
