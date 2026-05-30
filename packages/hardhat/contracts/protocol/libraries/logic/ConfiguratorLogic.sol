// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.10;

import {IPool} from '../../../interfaces/IPool.sol';

import {IInitializableAToken} from '../../../interfaces/IInitializableAToken.sol';

import {IInitializableDebtToken} from '../../../interfaces/IInitializableDebtToken.sol';
import {IAaveIncentivesController} from '../../../interfaces/IAaveIncentivesController.sol';
import {ReserveConfiguration} from '../configuration/ReserveConfiguration.sol';

import {DataTypes} from '../types/DataTypes.sol';

import {ConfiguratorInputTypes} from '../types/ConfiguratorInputTypes.sol';

/**
 * @title ConfiguratorLogic library
 * @author Aave
 * @notice Implements the functions to initialize reserves and update aTokens and debtTokens
 */
library ConfiguratorLogic {

using ReserveConfiguration
for DataTypes.ReserveConfigurationMap;

/**

* ---
* EVENTS
* ---

*/

event ReserveInitialized(
address indexed asset,
address indexed aToken,
address stableDebtToken,
address variableDebtToken,
address interestRateStrategyAddress
);

event ATokenUpgraded(
address indexed asset,
address indexed proxy,
address indexed implementation
);

event StableDebtTokenUpgraded(
address indexed asset,
address indexed proxy,
address indexed implementation
);

event VariableDebtTokenUpgraded(
address indexed asset,
address indexed proxy,
address indexed implementation
);

/**

* ---
* INIT RESERVE
* ---

*/

function executeInitReserve(
IPool pool,
ConfiguratorInputTypes
.InitReserveInput calldata input
) public {

/**
 * ---------------------------------------------------
 * DIRECT IMPLEMENTATION
 * ---------------------------------------------------
 */

address aTokenAddress =
  input.aTokenImpl;

address stableDebtTokenAddress =
  input.stableDebtTokenImpl;

address variableDebtTokenAddress =
  input.variableDebtTokenImpl;

/**
 * ---------------------------------------------------
 * INITIALIZE TOKENS
 * ---------------------------------------------------
 */

IInitializableAToken(
  aTokenAddress
).initialize(
  pool,
  input.treasury,
  input.underlyingAsset,
  IAaveIncentivesController(input.incentivesController),
  input.underlyingAssetDecimals,
  input.aTokenName,
  input.aTokenSymbol,
  input.params
);

IInitializableDebtToken(
  stableDebtTokenAddress
).initialize(
  pool,
  input.underlyingAsset,
  IAaveIncentivesController(input.incentivesController),
  input.underlyingAssetDecimals,
  input.stableDebtTokenName,
  input.stableDebtTokenSymbol,
  input.params
);

IInitializableDebtToken(
  variableDebtTokenAddress
).initialize(
  pool,
  input.underlyingAsset,
  IAaveIncentivesController(input.incentivesController),
  input.underlyingAssetDecimals,
  input.variableDebtTokenName,
  input.variableDebtTokenSymbol,
  input.params
);

/**
 * ---------------------------------------------------
 * INIT RESERVE
 * ---------------------------------------------------
 */

pool.initReserve(
  input.underlyingAsset,
  aTokenAddress,
  stableDebtTokenAddress,
  variableDebtTokenAddress,
  input.interestRateStrategyAddress
);

/**
 * ---------------------------------------------------
 * CONFIGURATION
 * ---------------------------------------------------
 */

DataTypes
  .ReserveConfigurationMap
    memory currentConfig =
      DataTypes
        .ReserveConfigurationMap(
          0
        );

currentConfig.setDecimals(
  input
    .underlyingAssetDecimals
);

currentConfig.setActive(true);

currentConfig.setPaused(false);

currentConfig.setFrozen(false);

pool.setConfiguration(
  input.underlyingAsset,
  currentConfig
);

/**
 * ---------------------------------------------------
 * EVENT
 * ---------------------------------------------------
 */

emit ReserveInitialized(
  input.underlyingAsset,
  aTokenAddress,
  stableDebtTokenAddress,
  variableDebtTokenAddress,
  input
    .interestRateStrategyAddress
);

}

/**

* ---
* UPDATE ATOKEN
* ---

*/

function executeUpdateAToken(
IPool cachedPool,
ConfiguratorInputTypes
.UpdateATokenInput calldata input
) public {

DataTypes
  .ReserveData
    memory reserveData =
      cachedPool
        .getReserveData(
          input.asset
        );

emit ATokenUpgraded(
  input.asset,
  reserveData.aTokenAddress,
  input.implementation
);

}

/**

* ---
* UPDATE STABLE DEBT TOKEN
* ---

*/

function executeUpdateStableDebtToken(
IPool cachedPool,
ConfiguratorInputTypes
.UpdateDebtTokenInput calldata input
) public {

DataTypes
  .ReserveData
    memory reserveData =
      cachedPool
        .getReserveData(
          input.asset
        );

emit StableDebtTokenUpgraded(
  input.asset,
  reserveData
    .stableDebtTokenAddress,
  input.implementation
);

}

/**

* ---
* UPDATE VARIABLE DEBT TOKEN
* ---

*/

function executeUpdateVariableDebtToken(
IPool cachedPool,
ConfiguratorInputTypes
.UpdateDebtTokenInput calldata input
) public {

DataTypes
  .ReserveData
    memory reserveData =
      cachedPool
        .getReserveData(
          input.asset
        );

emit VariableDebtTokenUpgraded(
  input.asset,
  reserveData
    .variableDebtTokenAddress,
  input.implementation
);

}
}
