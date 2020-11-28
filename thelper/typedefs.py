"""
Typing definitions for thelper.
"""

import io
import typing

import matplotlib.pyplot as plt
import numpy as np
import torch

ModelType = "thelper.nn.Module"
LoaderType = "thelper.data.loaders.DataLoader"
TaskType = "thelper.tasks.Task"
BoundingBox = "thelper.tasks.detect.BoundingBox"

ArrayType = np.ndarray  # generic definition
ArrayShapeType = typing.Union[typing.List[int], typing.Tuple[int]]
OneOrManyArrayType = typing.Union[typing.List[ArrayType], ArrayType]

ClassIdType = typing.Union[typing.AnyStr, int]
LabelColorMapType = typing.Union[ArrayType, typing.Dict[int, ArrayType]]
LabelIndex = typing.AnyStr
LabelType = typing.AnyStr
LabelDict = typing.Dict[LabelIndex, LabelType]
LabelList = typing.Sequence[LabelType]  # list/set/tuple
LabelMapping = typing.Union[LabelList, LabelDict]
ReversedLabelMapping = typing.Dict[LabelType, LabelIndex]
DrawingType = typing.Optional[typing.Tuple[plt.Figure, plt.Axes]]
ClassColorMap = typing.Dict[ClassIdType, typing.Union[int, typing.Tuple[int, int, int]]]

Number = typing.Union[int, float]
_literalJSON = typing.Optional[typing.Union[typing.AnyStr, Number, bool]]
JSON = typing.Union[_literalJSON, typing.List[typing.Union[_literalJSON, "JSON"]],
                    typing.Dict[typing.AnyStr, typing.Union[_literalJSON, "JSON"]]]

SampleType = typing.Dict[typing.Union[typing.AnyStr, int], typing.Any]
InputType = torch.Tensor

ClassificationPredictionType = torch.Tensor
ClassificationTargetType = torch.Tensor
SegmentationPredictionType = torch.Tensor
SegmentationTargetType = torch.Tensor
DetectionPredictionType = typing.List[typing.List[BoundingBox]]
DetectionTargetType = typing.List[typing.List[BoundingBox]]
RegressionPredictionType = torch.Tensor
RegressionTargetType = torch.Tensor

AnyPredictionType = typing.Union[ClassificationPredictionType,
                                 SegmentationPredictionType,
                                 DetectionPredictionType,
                                 RegressionPredictionType]
AnyTargetType = typing.Union[ClassificationTargetType,
                             SegmentationTargetType,
                             DetectionTargetType,
                             RegressionTargetType]

ConfigIndex = typing.AnyStr
ConfigValue = typing.Union[typing.AnyStr, bool, float, int, typing.List[typing.Any],
                           typing.Dict[typing.Any, typing.Any]]
ConfigDict = typing.Dict[ConfigIndex, typing.Union[ConfigValue, "ConfigDict"]]

CheckpointLoadingType = typing.Union[typing.AnyStr, io.FileIO]
CheckpointContentType = typing.Dict[typing.AnyStr, typing.Any]
MapLocationType = typing.Union[typing.Callable, typing.AnyStr,
                               typing.Dict[typing.AnyStr, typing.AnyStr]]

MultiLoaderType = typing.Tuple[typing.Optional[LoaderType],
                               typing.Optional[LoaderType],
                               typing.Optional[LoaderType]]

IterCallbackType = typing.Callable[
    [TaskType,
     InputType,
     AnyPredictionType,
     AnyTargetType,
     SampleType,
     typing.Optional[float],
     int,
     int,
     int,
     int,
     typing.AnyStr],
    None
]
IterCallbackParams = [
    "task",         # the task object that defines class names, min/max target values, etc.
    "input",        # the (batched) input tensor given to the model in order to generate a prediction
    "pred",         # the (batched) tensor generated by the model containing predicted value(s)
    "target",       # the (batched) tensor containing target (groundtruth) prediction value(s)
    "sample",       # the mini-batch sample dictionary assembled by the data loader
    "loss",         # the loss computed by the model for the current iteration (may be None)
    "iter_idx",     # the index of the iteration (or sample index) in the current epoch
    "max_iters",    # the total number of iterations in the current epoch
    "epoch_idx",    # the index of the current epoch
    "max_epochs",   # the total (maximum) number of epochs the model should be trained for
    "output_path",  # directory where output files should be written, if necessary
]
