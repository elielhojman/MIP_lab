#include <cstdio>
#include <cmath>
#include "maxflow/graph.h"



#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkImageRegionIteratorWithIndex.h"


#include "vnl/vnl_vector.h"


#include "itkBinaryErodeImageFilter.h"
#include "itkBinaryDilateImageFilter.h"
#include "itkBinaryBallStructuringElement.h"

#include "itkLabelStatisticsImageFilter.h"
#define EPSILON 0.001
#define MORPH_RAD 1

enum {BACKGROUND=0, FOREGROUND};
enum {APP = 0,INPUT_IMAGE,OUTPUT_IMAGE,SHAPE_IMAGE,LIKELIHOOD_IMAGE,ARGS_NUM};




double computeEdgeWeight (double a, double b)
{
   
    double diff = (b-a)*(b-a);
    double val = exp (-(diff));
    return val;
}

int main( int argc, char * argv [] )
{	
	
    if( argc < ARGS_NUM )
    {
        std::cerr << "Usage: " << std::endl;
        std::cerr << argv[APP];
        std::cerr << "  INPUT_IMAGE OUTPUT_IMAGE SHAPE_IMAGE LIKELIHOOD_IMAGE" << std::endl;
        return EXIT_FAILURE;
    }
        
    const char *inputImageFileName        = argv[INPUT_IMAGE];
    const char *outputImageFileName       = argv[OUTPUT_IMAGE];
    const char *shapeImageFileName        = argv[SHAPE_IMAGE];
    const char *likelihoodImageFileName   = argv[LIKELIHOOD_IMAGE];
        
    typedef float       PixelType;
    typedef unsigned char      SegPixelType;
    const unsigned int         Dimension = 3;
        
    typedef itk::Image<PixelType, Dimension > ImageType;
    typedef itk::Image<SegPixelType, Dimension > SegImageType;
 	
    typedef itk::ImageRegionIteratorWithIndex< ImageType > itkImageRegionIteratorWithIndexType;
    typedef itk::ImageRegionIteratorWithIndex< SegImageType > itkSegImageRegionIteratorWithIndexType;
        
        
    typedef itk::ImageFileReader< ImageType > ReaderType;
    typedef itk::ImageFileReader< SegImageType > SegReaderType;
	
	
    ReaderType::Pointer imageReader = ReaderType::New();
    imageReader->SetFileName( inputImageFileName );
    try
    {
        imageReader->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
        std::cerr << "Problem encountered while reading ";
        std::cerr << " image file : " << inputImageFileName << std::endl;
        std::cerr << excp << std::endl;
        return EXIT_FAILURE;
    }
        
    ReaderType::Pointer shapeReader = ReaderType::New();
    shapeReader->SetFileName(shapeImageFileName);
    try
    {
        shapeReader->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
        std::cerr << "Problem encountered while reading ";
        std::cerr << " image file : " << shapeImageFileName << std::endl;
        std::cerr << excp << std::endl;
        return EXIT_FAILURE;
    }
    
    ReaderType::Pointer likelihoodReader = ReaderType::New();
    likelihoodReader->SetFileName(likelihoodImageFileName);
    try
    {
        likelihoodReader->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
        std::cerr << "Problem encountered while reading ";
        std::cerr << " image file : " << likelihoodImageFileName << std::endl;
        std::cerr << excp << std::endl;
        return EXIT_FAILURE;
    }
   

    ImageType::Pointer imageVolume = imageReader->GetOutput();
    ImageType::Pointer shapeVolume = shapeReader->GetOutput();
    ImageType::Pointer likelihoodVolume = likelihoodReader->GetOutput();
	
    const ImageType::SizeType & size = imageVolume->GetLargestPossibleRegion().GetSize();
    double mean, std;
	

	
    int num_of_nodes =  size[0]*size[1]*size[2];
    int num_of_edges = num_of_nodes*6;
    std::cout << "num_of_nodes: " << num_of_nodes << std::endl;
    std::cout << "num_of_edges: " << num_of_edges << std::endl;

	
    itkImageRegionIteratorWithIndexType imageIt( imageVolume, imageVolume->GetLargestPossibleRegion() );
    itkImageRegionIteratorWithIndexType targetIt( imageVolume, imageVolume->GetLargestPossibleRegion() );
    itkImageRegionIteratorWithIndexType shapeIt( shapeVolume, shapeVolume->GetLargestPossibleRegion() );
    itkImageRegionIteratorWithIndexType likelihoodIt( likelihoodVolume, likelihoodVolume->GetLargestPossibleRegion() );
	
    float edge_weight = 0;
    float source_weight = 0;
    float sink_weight = 0;

    typedef Graph<float,float,float> GraphType;
    GraphType *g = new GraphType( num_of_nodes,  num_of_edges); 

    g->add_node (num_of_nodes);
    int node_num;
    int to_node;
    
    const ImageType::SizeType & max_size = imageVolume->GetLargestPossibleRegion().GetSize(); 
    int count = 0;
    
    
    for (imageIt.GoToBegin(), shapeIt.GoToBegin(), likelihoodIt.GoToBegin(); !imageIt.IsAtEnd();++imageIt, ++shapeIt, ++likelihoodIt)
    {
	
        const ImageType::IndexType &index = imageIt.GetIndex ();
        node_num = index[2]*(size[1]*size[0]) + index[1]*size[0] + index[0];      
        
       
        source_weight = likelihoodIt.Value() * shapeIt.Value();
        sink_weight   = 1 - source_weight;
        
        g -> add_tweights( node_num, source_weight, sink_weight );
        ImageType::IndexType target_index;
        target_index[0] = index[0];
        target_index[1] = index[1];
        target_index[2] = index[2];
		
        //calculate the weights of edges connecting the node to its neighbors (overall six edges, two in each axis)
       
        if (target_index[2]-1 >= 0)
        {
            target_index[2] -=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value() ) ;
            g -> add_edge( node_num, to_node, edge_weight, edge_weight);
        }
        target_index[2] = index[2];
        if (index[2]+1 < size[2])
        {
            target_index[2] +=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value() );
            g -> add_edge( node_num, to_node, edge_weight, edge_weight);
        }
        target_index[2] = index[2];

        if (index[1]-1 >= 0)
        {
            target_index[1] -=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value() );
            g -> add_edge( node_num, to_node, edge_weight, edge_weight);
        }
        target_index[1] = index[1];
		

        if (index[1]+1 < size[1])
        {
            target_index[1] +=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value() );
            g -> add_edge( node_num, to_node, edge_weight, edge_weight);
        }
        target_index[1] = index[1];
		
        if (index[0]-1 >= 0)
        {
            target_index[0] -=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value() );
            g -> add_edge( node_num, to_node, edge_weight, edge_weight);
        }
        target_index[0] = index[0];
		
        if (index[0]+1 < size[0])
        {
            target_index[0] +=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value() );
            g -> add_edge( node_num, to_node, edge_weight, edge_weight);
        }
        target_index[0] = index[0];

    }
    
    std::cout << "end to build graph " << std::endl;

    //Perform MAX FLOW algorithm on the graph
    float flow = g -> maxflow();
    std::cout << "end to compute maxflow " << std::endl;


    SegImageType::Pointer outputVolume =   SegImageType::New();
    outputVolume->SetOrigin (imageVolume->GetOrigin());
    outputVolume->SetSpacing (imageVolume->GetSpacing());
    outputVolume->SetRegions (imageVolume->GetLargestPossibleRegion());
    outputVolume->Allocate();
    outputVolume->FillBuffer (0);


	
	

    itkSegImageRegionIteratorWithIndexType outputIt( outputVolume, outputVolume->GetLargestPossibleRegion() );

    for (outputIt.GoToBegin();!outputIt.IsAtEnd(); ++outputIt)
    {
        const ImageType::IndexType &index = outputIt.GetIndex ();
        node_num = index[2]*(size[1]*size[0]) + index[1]*size[0] + index[0];
		
        if (g->what_segment(node_num) == GraphType::SOURCE)
        {
            outputIt.Value() = FOREGROUND;
        }
        else
        {
            outputIt.Value() = BACKGROUND;
        }
    }
	
    delete g;
    std::cout << "end to update graph cut output image " << std::endl;

	
	
	


    // morphological cleaning
    typedef itk::BinaryBallStructuringElement<unsigned char, 3 > StructuringElementType;
    typedef itk::BinaryErodeImageFilter< SegImageType, SegImageType, StructuringElementType > ErodeFilterType;
    typedef itk::BinaryDilateImageFilter< SegImageType, SegImageType, StructuringElementType > DilateFilterType;
    
    ErodeFilterType::Pointer binaryErode = ErodeFilterType::New();
    DilateFilterType::Pointer binaryDilate = DilateFilterType::New();
    StructuringElementType structuringElement;
    unsigned int morph_rad = MORPH_RAD;
    structuringElement.SetRadius( morph_rad );
    structuringElement.CreateStructuringElement();
    binaryErode->SetKernel( structuringElement );
    binaryDilate->SetKernel( structuringElement );
    
    binaryErode->SetErodeValue(FOREGROUND );
    binaryDilate->SetDilateValue( FOREGROUND );
    
    
    
    
    binaryErode->SetInput( outputVolume    );
    binaryDilate->SetInput( binaryErode->GetOutput()  );
    
    binaryDilate->Update();
    
    //     // morphological cleaning
    // typedef itk::OrderedConnectedImageFilter <SegImageType, SegImageType> itkOrderedConnectedImageFilterType;
    // itkOrderedConnectedImageFilterType::Pointer con = itkOrderedConnectedImageFilterType::New();
    // con->SetInput (outputVolume);
    // con->SetComponentsNum (1); //choose largest connected components only
    // con->Update();
	

	

    typedef itk::ImageFileWriter< SegImageType > SegWriterType;
    SegWriterType::Pointer writer = SegWriterType::New();
    writer->SetFileName( outputImageFileName );
    writer->SetInput (binaryDilate->GetOutput());//outputVolume);
  
    try
    {
        writer->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
        std::cerr << "Problem encountered while writing ";
        std::cerr << " image file : " << outputImageFileName << std::endl;
        std::cerr << excp << std::endl;
        return EXIT_FAILURE;
    }

    typedef itk::ImageFileWriter< SegImageType > SegWriterType;
    SegWriterType::Pointer beforeMorphWriter = SegWriterType::New();
    beforeMorphWriter->SetFileName( "beforeMorphGC.nii.gz" );
    beforeMorphWriter->SetInput (outputVolume);
  
    try
    {
        beforeMorphWriter->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
        std::cerr << "Problem encountered while writing ";
        std::cerr << " image file : " << outputImageFileName << std::endl;
        std::cerr << excp << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
