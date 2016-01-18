# This is the root ITK CMakeLists file.
CMAKE_MINIMUM_REQUIRED(VERSION 2.4)
IF(COMMAND CMAKE_POLICY)
  CMAKE_POLICY(SET CMP0003 NEW)
ENDIF(COMMAND CMAKE_POLICY)


# This project is designed to be built outside the Insight source tree.
PROJECT(graph_cut)

# Find ITK.
FIND_PACKAGE(ITK REQUIRED)
INCLUDE(${ITK_USE_FILE})
 


ADD_EXECUTABLE(graph_cut graph_cut.cxx )

TARGET_LINK_LIBRARIES( graph_cut
						ITKDICOMParser
						ITKStatistics
						ITKIO
						ITKNumerics
						ITKBasicFilters
						ITKAlgorithms
						ITKFEM
						ITKEXPAT
						itkgdcm
						ITKNrrdIO
						ITKniftiio
						ITKMetaIO
						ITKSpatialObject
						itkpng
						itkvnl_algo
						itkvcl
						         
					)

 #ITKDICOMP
