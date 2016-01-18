#include <cstdio>
#include <cmath>
#include "graph.h"



#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkImageRegionIteratorWithIndex.h"


#include "vnl/vnl_vector.h"


#include "itkBinaryErodeImageFilter.h"
#include "itkBinaryDilateImageFilter.h"
#include "itkBinaryBallStructuringElement.h"

#include "itkOrderedConnectedImageFilter.h"
#include "itkLabelStatisticsImageFilter.h"
#define EPSILON 0.001
enum {BACKGROUND=0, FOREGROUND};
enum {APP = 0,INPUT_IMAGE,OUTPUT_IMAGE,SHAPE_IMAGE,LIKELIHOOD_IMAGE,ZERO_CROSSIMG_IMAGE,LABEL,INTENSITY_PARAMS_FILE,ARGS_NUM};




double computeEdgeWeight (double a, double b, double sigma, bool highShape)
{
    double val;
    if ((a*b) < 0)
    {
        val = 0.00001;
    }
    double diff = (b-a)*(b-a);
    val = exp (-(diff)/(sigma*sigma));
    if (highShape == true)
    {
        return val * 2;
    }
    else
    {
        return val;
    }
}

int main( int argc, char * argv [] )
{	
	
    if( argc < ARGS_NUM )
    {
        std::cerr << "Usage: " << std::endl;
        std::cerr << argv[APP];
        std::cerr << "  INPUT_IMAGE OUTPUT_IMAGE SHAPE_IMAGE LIKELIHOOD_IMAGE ZERO_CROSSIMG_IMAGE LABEL INTENSITY_PARAMS_FILE" << std::endl;
        return EXIT_FAILURE;
    }
        
    const char *inputImageFileName        = argv[INPUT_IMAGE];
    const char *outputImageFileName       = argv[OUTPUT_IMAGE];
    const char *shapeImageFileName        = argv[SHAPE_IMAGE];
    const char *likelihoodImageFileName   = argv[LIKELIHOOD_IMAGE];
    const char *zeroCrossingImageFileName = argv[ZERO_CROSSIMG_IMAGE];
    const char *intensityParamsFileName   = argv[INTENSITY_PARAMS_FILE];
    const unsigned int label = atoi(argv[LABEL]);
        
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
    
    SegReaderType::Pointer zeroCrossingReader = SegReaderType::New();
    zeroCrossingReader->SetFileName( zeroCrossingImageFileName );
    try
    {
        zeroCrossingReader->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
        std::cerr << "Problem encountered while reading ";
        std::cerr << " image file : " << zeroCrossingImageFileName << std::endl;
        std::cerr << excp << std::endl;
        return EXIT_FAILURE;
    }

    ImageType::Pointer imageVolume = imageReader->GetOutput();
    ImageType::Pointer shapeVolume = shapeReader->GetOutput();
    ImageType::Pointer likelihoodVolume = likelihoodReader->GetOutput();
    SegImageType::Pointer zeroCrossingVolume = zeroCrossingReader->GetOutput();

	
    const ImageType::SizeType & size = imageVolume->GetLargestPossibleRegion().GetSize();
    double mean, std;
	

	

	

    //get object mean and std from file
    std::fstream f;
    f.open (intensityParamsFileName, std::ios::in);
    f >>  mean >> std;
    f.close ();
    std::cout<<"object mean: "<<mean<<"\nobject std: "<<std<<"\n";
	
    int num_of_nodes =  size[0]*size[1]*size[2];
    int num_of_edges = num_of_nodes*6;
    std::cout << "num_of_nodes: " << num_of_nodes << std::endl;
    std::cout << "num_of_edges: " << num_of_edges << std::endl;

	
    itkImageRegionIteratorWithIndexType imageIt( imageVolume, imageVolume->GetLargestPossibleRegion() );
    itkImageRegionIteratorWithIndexType targetIt( imageVolume, imageVolume->GetLargestPossibleRegion() );
    itkImageRegionIteratorWithIndexType shapeIt( shapeVolume, shapeVolume->GetLargestPossibleRegion() );
    itkImageRegionIteratorWithIndexType likelihoodIt( likelihoodVolume, likelihoodVolume->GetLargestPossibleRegion() );
    itkSegImageRegionIteratorWithIndexType zeroCrossingIt( zeroCrossingVolume, zeroCrossingVolume->GetLargestPossibleRegion() );
	
    float edge_weight = 0;
    float source_weight = 0;
    float sink_weight = 0;

    typedef Graph<float,float,float> GraphType;
    GraphType *g = new GraphType( num_of_nodes,  num_of_edges); 

    g->add_node (num_of_nodes);
    int node_num;
    int to_node;
    double sigma = std;
    
    const ImageType::SizeType & max_size = imageVolume->GetLargestPossibleRegion().GetSize(); 
    int count = 0;
    
    
    for (imageIt.GoToBegin(), shapeIt.GoToBegin(), likelihoodIt.GoToBegin(), zeroCrossingIt.GoToBegin(); !imageIt.IsAtEnd();++imageIt, ++shapeIt, ++likelihoodIt, ++zeroCrossingIt)
    {
	
        const ImageType::IndexType &index = imageIt.GetIndex ();
        node_num = index[2]*(size[1]*size[0]) + index[1]*size[0] + index[0];
        
        if (shapeIt.Value() >= 0.8 && imageIt.Value() > 0)
        {
            source_weight = 1;
            sink_weight = 0;
        }
        
        else if (imageIt.Value() < -40 || imageIt.Value() > 400 || shapeIt.Value() < 0.01)
        {
            source_weight = 0;
            sink_weight = 1;
        }
        
        else
        {
            double normalizationFactor = likelihoodIt.Value()*shapeIt.Value() + (1-likelihoodIt.Value()) * (1-shapeIt.Value());
            //std::cout<<"like: "<<likelihoodIt.Value()<<" shape: "<<shapeIt.Value()<<" normalizationFactor: "<<normalizationFactor<<"\n";
            if(normalizationFactor == 0)
            {
                source_weight = 0.5;
                sink_weight   = 0.5; 
            }
            else
            {
                double regularizedLikelihood, regularizedShape, regularizedNormalizationFactor;
                if(likelihoodIt.Value() == 1)
                {
                    regularizedLikelihood = 1 - EPSILON;
                }
                else if(likelihoodIt.Value() == 0)
                {
                    regularizedLikelihood = EPSILON;
                }
                else
                {
                    regularizedLikelihood = likelihoodIt.Value();
                }
                
                if(shapeIt.Value() == 1)
                {
                    regularizedShape = 1 - EPSILON;
                }
                else if(shapeIt.Value() == 0)
                {
                    regularizedShape = EPSILON;
                }
                else
                {
                    regularizedShape = shapeIt.Value();
                }
                regularizedNormalizationFactor = regularizedLikelihood * regularizedShape + (1 - regularizedLikelihood) * (1 - regularizedShape);
                source_weight = (regularizedLikelihood * regularizedShape)/(regularizedNormalizationFactor);
                sink_weight   = ((1-regularizedLikelihood) * (1-regularizedShape))/(regularizedNormalizationFactor);
            }
            
        }
        g -> add_tweights( node_num, source_weight, sink_weight );
        ImageType::IndexType target_index;
        target_index[0] = index[0];
        target_index[1] = index[1];
        target_index[2] = index[2];
		
        //calculate the weights of edges connecting the node to its neighbors (overall six edges, two in each axis)
        bool highShape = false;
        if(shapeIt.Value() >= 0.6)
        {
            highShape = true;
        }
        if (target_index[2]-1 >= 0)
        {
            target_index[2] -=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value(),sigma,highShape ) ;
            g -> add_edge( node_num, to_node, edge_weight, edge_weight);
        }
        target_index[2] = index[2];
        if (index[2]+1 < size[2])
        {
            target_index[2] +=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value(),sigma,highShape );
            g -> add_edge( node_num, to_node, edge_weight, edge_weight);
        }
        target_index[2] = index[2];

        if (index[1]-1 >= 0)
        {
            target_index[1] -=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value(),sigma,highShape );
            g -> add_edge( node_num, to_node, edge_weight, edge_weight);
        }
        target_index[1] = index[1];
		

        if (index[1]+1 < size[1])
        {
            target_index[1] +=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value(),sigma,highShape );
            g -> add_edge( node_num, to_node, edge_weight, edge_weight);
        }
        target_index[1] = index[1];
		
        if (index[0]-1 >= 0)
        {
            target_index[0] -=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value(),sigma,highShape );
            g -> add_edge( node_num, to_node, edge_weight, edge_weight);
        }
        target_index[0] = index[0];
		
        if (index[0]+1 < size[0])
        {
            target_index[0] +=1;
            to_node = target_index[2]*(size[1]*size[0]) + target_index[1]*size[0] + target_index[0];
            targetIt.SetIndex (target_index);
            edge_weight = computeEdgeWeight (imageIt.Value(), targetIt.Value(),sigma,highShape );
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

	
	
    typedef itk::OrderedConnectedImageFilter <SegImageType, SegImageType> itkOrderedConnectedImageFilterType;
    itkOrderedConnectedImageFilterType::Pointer con = itkOrderedConnectedImageFilterType::New();
    con->SetInput (outputVolume);
    con->SetComponentsNum (1); //choose largest connected components only
    con->Update();
	

	

    typedef itk::ImageFileWriter< SegImageType > SegWriterType;
    SegWriterType::Pointer writer = SegWriterType::New();
    writer->SetFileName( outputImageFileName );
    writer->SetInput (/*outputVolume*/con->GetOutput());
  
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

    return EXIT_SUCCESS;
}
