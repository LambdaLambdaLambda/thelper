"""
Typing definitions for thelper.
"""

import io
from typing import TYPE_CHECKING, Any, AnyStr, Callable, Dict, List, Optional, Tuple, Union  # noqa: F401

import matplotlib.pyplot as plt
import numpy as np
from torch import Tensor

if TYPE_CHECKING:
    from thelper.tasks.utils import Task

    ArrayType = np.ndarray
    ArrayShapeType = Union[List[int], Tuple[int]]
    OneOrManyArrayType = Union[List[ArrayType], ArrayType]
    LabelColorMapType = Union[ArrayType, Dict[int, ArrayType]]
    LabelIndex = AnyStr
    LabelType = AnyStr
    LabelDict = Dict[LabelIndex, LabelType]
    LabelList = List[LabelType]
    DrawingType = Union[Tuple[plt.Figure, plt.Axes], None]

    # iteration callbacks should have the following signature:
    #   func(sample, pred, iter_idx, max_iters, epoch_idx, max_epochs)
    SampleType = Dict[Union[AnyStr, int], Tensor]
    PredictionType = Tensor
    IterCallbackType = Optional[Callable[[SampleType, Task, PredictionType, int, int, int, int], None]]

    ConfigIndex = AnyStr
    ConfigValue = Union[AnyStr, bool, float, int]
    ConfigDict = Dict[ConfigIndex, ConfigValue]

    CheckpointLoadingType = Union[AnyStr, io.FileIO]
    CheckpointContentType = Dict[AnyStr, Any]
    MapLocationType = Union[Callable, AnyStr, Dict[AnyStr, AnyStr]]

IterCallbackParams = ["sample", "task", "pred", "iter_idx", "max_iters", "epoch_idx", "max_epochs"]