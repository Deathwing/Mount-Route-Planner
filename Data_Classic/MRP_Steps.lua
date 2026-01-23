-- MRP_Steps.lua
-- local _, MRP = ...

---@type Step[]
local steps = {
  {
    id = 1,
    mounts = {
      {
        id = 395,
        name = "Drake of the North Wind",
        icon = "interface/icons/inv_misc_stormdragonpale.blp",
        itemId = 63040,
        spellId = 88742,
        source = {
          mapId = 657,
          uiMapIds = {
            325
          },
          allowedDifficultyIds = {
            1,
            2
          },
          journalEncounter = {
            id = 115,
            name = "Altairus",
            instanceId = 68,
            uiMapId = 325
          },
          dungeonEncounter = {
            id = 1041,
            name = "Altairus",
            mapId = 657
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "The Vortex Pinnacle"
    },
    expansion = 3
  },
  {
    id = 2,
    mounts = {
      {
        id = 396,
        name = "Drake of the South Wind",
        icon = "interface/icons/inv_misc_stormdragonpurple.blp",
        itemId = 63041,
        spellId = 88744,
        source = {
          mapId = 754,
          uiMapIds = {
            328
          },
          allowedDifficultyIds = {
            3,
            4,
            5,
            6
          },
          journalEncounter = {
            id = 155,
            name = "Al'Akir",
            instanceId = 74,
            uiMapId = 328
          },
          dungeonEncounter = {
            id = 1034,
            name = "Al'Akir",
            mapId = 754
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Throne of the Four Winds"
    },
    expansion = 3
  },
  {
    id = 3,
    mounts = {
      {
        id = 117,
        name = "Blue Qiraji Battle Tank",
        icon = "interface/icons/inv_misc_qirajicrystal_04.blp",
        itemId = 21218,
        spellId = 25953,
        source = {
          mapId = 531,
          uiMapIds = {
            319,
            320,
            321
          },
          allowedDifficultyIds = {
            9
          },
          specialEncounter = {
            name = "Trash"
          }
        }
      },
      {
        id = 120,
        name = "Green Qiraji Battle Tank",
        icon = "interface/icons/inv_misc_qirajicrystal_03.blp",
        itemId = 21323,
        spellId = 26056,
        source = {
          mapId = 531,
          uiMapIds = {
            319,
            320,
            321
          },
          allowedDifficultyIds = {
            9
          },
          specialEncounter = {
            name = "Trash"
          }
        }
      },
      {
        id = 119,
        name = "Yellow Qiraji Battle Tank",
        icon = "interface/icons/inv_misc_qirajicrystal_01.blp",
        itemId = 21324,
        spellId = 26055,
        source = {
          mapId = 531,
          uiMapIds = {
            319,
            320,
            321
          },
          allowedDifficultyIds = {
            9
          },
          specialEncounter = {
            name = "Trash"
          }
        }
      },
      {
        id = 118,
        name = "Red Qiraji Battle Tank",
        icon = "interface/icons/inv_misc_qirajicrystal_02.blp",
        itemId = 21321,
        spellId = 26054,
        source = {
          mapId = 531,
          uiMapIds = {
            319,
            320,
            321
          },
          allowedDifficultyIds = {
            9
          },
          specialEncounter = {
            name = "Trash"
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Temple of Ahn'Qiraj"
    },
    expansion = 0
  },
  {
    id = 4,
    mounts = {
      {
        id = 349,
        name = "Onyxian Drake",
        icon = "interface/icons/achievement_boss_onyxia.blp",
        itemId = 49636,
        spellId = 69395,
        source = {
          mapId = 249,
          uiMapIds = {
            248
          },
          allowedDifficultyIds = {
            3,
            4
          },
          journalEncounter = {
            id = 1651,
            name = "Onyxia",
            instanceId = 760,
            uiMapId = 248
          },
          dungeonEncounter = {
            id = 1084,
            name = "Onyxia",
            mapId = 249
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Onyxia's Lair"
    },
    expansion = 2
  },
  {
    id = 5,
    mounts = {
      {
        id = 363,
        name = "Invincible",
        icon = "interface/icons/ability_mount_pegasus.blp",
        itemId = 50818,
        spellId = 72286,
        source = {
          mapId = 631,
          uiMapIds = {
            192
          },
          allowedDifficultyIds = {
            6
          },
          journalEncounter = {
            id = 1636,
            name = "The Lich King",
            instanceId = 758,
            uiMapId = 192
          },
          dungeonEncounter = {
            id = 1106,
            name = "The Lich King",
            mapId = 631
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Icecrown Citadel"
    },
    expansion = 2
  },
  {
    id = 6,
    mounts = {
      {
        id = 286,
        name = "Grand Black War Mammoth",
        icon = "interface/icons/ability_mount_mammoth_black.blp",
        itemId = 43959,
        spellId = 61465,
        source = {
          mapId = 624,
          uiMapIds = {
            156
          },
          allowedDifficultyIds = {
            3,
            4
          },
          factionMask = -2,
          journalEncounter = {
            id = 1599,
            name = "Koralon the Flame Watcher",
            instanceId = 753,
            uiMapId = 156
          },
          dungeonEncounter = {
            id = 1128,
            name = "Koralon the Flame Watcher",
            mapId = 624
          }
        }
      },
      {
        id = 286,
        name = "Grand Black War Mammoth",
        icon = "interface/icons/ability_mount_mammoth_black.blp",
        itemId = 43959,
        spellId = 61465,
        source = {
          mapId = 624,
          uiMapIds = {
            156
          },
          allowedDifficultyIds = {
            3,
            4
          },
          factionMask = -2,
          journalEncounter = {
            id = 1600,
            name = "Toravon the Ice Watcher",
            instanceId = 753,
            uiMapId = 156
          },
          dungeonEncounter = {
            id = 1129,
            name = "Toravon the Ice Watcher",
            mapId = 624
          }
        }
      },
      {
        id = 286,
        name = "Grand Black War Mammoth",
        icon = "interface/icons/ability_mount_mammoth_black.blp",
        itemId = 43959,
        spellId = 61465,
        source = {
          mapId = 624,
          uiMapIds = {
            156
          },
          allowedDifficultyIds = {
            3,
            4
          },
          factionMask = -2,
          journalEncounter = {
            id = 1597,
            name = "Archavon the Stone Watcher",
            instanceId = 753,
            uiMapId = 156
          },
          dungeonEncounter = {
            id = 1126,
            name = "Archavon the Stone Watcher",
            mapId = 624
          }
        }
      },
      {
        id = 286,
        name = "Grand Black War Mammoth",
        icon = "interface/icons/ability_mount_mammoth_black.blp",
        itemId = 43959,
        spellId = 61465,
        source = {
          mapId = 624,
          uiMapIds = {
            156
          },
          allowedDifficultyIds = {
            3,
            4
          },
          factionMask = -2,
          journalEncounter = {
            id = 1598,
            name = "Emalon the Storm Watcher",
            instanceId = 753,
            uiMapId = 156
          },
          dungeonEncounter = {
            id = 1127,
            name = "Emalon the Storm Watcher",
            mapId = 624
          }
        }
      },
      {
        id = 287,
        name = "Grand Black War Mammoth",
        icon = "interface/icons/ability_mount_mammoth_black.blp",
        itemId = 44083,
        spellId = 61467,
        source = {
          mapId = 624,
          uiMapIds = {
            156
          },
          allowedDifficultyIds = {
            3,
            4
          },
          factionMask = -3,
          journalEncounter = {
            id = 1599,
            name = "Koralon the Flame Watcher",
            instanceId = 753,
            uiMapId = 156
          },
          dungeonEncounter = {
            id = 1128,
            name = "Koralon the Flame Watcher",
            mapId = 624
          }
        }
      },
      {
        id = 287,
        name = "Grand Black War Mammoth",
        icon = "interface/icons/ability_mount_mammoth_black.blp",
        itemId = 44083,
        spellId = 61467,
        source = {
          mapId = 624,
          uiMapIds = {
            156
          },
          allowedDifficultyIds = {
            3,
            4
          },
          factionMask = -3,
          journalEncounter = {
            id = 1600,
            name = "Toravon the Ice Watcher",
            instanceId = 753,
            uiMapId = 156
          },
          dungeonEncounter = {
            id = 1129,
            name = "Toravon the Ice Watcher",
            mapId = 624
          }
        }
      },
      {
        id = 287,
        name = "Grand Black War Mammoth",
        icon = "interface/icons/ability_mount_mammoth_black.blp",
        itemId = 44083,
        spellId = 61467,
        source = {
          mapId = 624,
          uiMapIds = {
            156
          },
          allowedDifficultyIds = {
            3,
            4
          },
          factionMask = -3,
          journalEncounter = {
            id = 1597,
            name = "Archavon the Stone Watcher",
            instanceId = 753,
            uiMapId = 156
          },
          dungeonEncounter = {
            id = 1126,
            name = "Archavon the Stone Watcher",
            mapId = 624
          }
        }
      },
      {
        id = 287,
        name = "Grand Black War Mammoth",
        icon = "interface/icons/ability_mount_mammoth_black.blp",
        itemId = 44083,
        spellId = 61467,
        source = {
          mapId = 624,
          uiMapIds = {
            156
          },
          allowedDifficultyIds = {
            3,
            4
          },
          factionMask = -3,
          journalEncounter = {
            id = 1598,
            name = "Emalon the Storm Watcher",
            instanceId = 753,
            uiMapId = 156
          },
          dungeonEncounter = {
            id = 1127,
            name = "Emalon the Storm Watcher",
            mapId = 624
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Vault of Archavon"
    },
    expansion = 2
  },
  {
    id = 7,
    mounts = {
      {
        id = 246,
        name = "Azure Drake",
        icon = "interface/icons/ability_mount_drake_azure.blp",
        itemId = 43952,
        spellId = 59567,
        source = {
          mapId = 616,
          uiMapIds = {
            141
          },
          allowedDifficultyIds = {
            3,
            4
          },
          journalEncounter = {
            id = 1617,
            name = "Malygos",
            instanceId = 756,
            uiMapId = 141
          },
          dungeonEncounter = {
            id = 1094,
            name = "Malygos",
            mapId = 616
          }
        }
      },
      {
        id = 247,
        name = "Blue Drake",
        icon = "interface/icons/ability_mount_drake_blue.blp",
        itemId = 43953,
        spellId = 59568,
        source = {
          mapId = 616,
          uiMapIds = {
            141
          },
          allowedDifficultyIds = {
            3,
            4
          },
          journalEncounter = {
            id = 1617,
            name = "Malygos",
            instanceId = 756,
            uiMapId = 141
          },
          dungeonEncounter = {
            id = 1094,
            name = "Malygos",
            mapId = 616
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "The Eye of Eternity"
    },
    expansion = 2
  },
  {
    id = 8,
    mounts = {
      {
        id = 253,
        name = "Black Drake",
        icon = "interface/icons/ability_mount_drake_twilight.blp",
        itemId = 43986,
        spellId = 59650,
        source = {
          mapId = 615,
          uiMapIds = {
            155
          },
          allowedDifficultyIds = {
            3
          },
          note = "All 3 outer dragons must still be alive when Sartharion was pulled in order for this mount to drop.",
          journalEncounter = {
            id = 1616,
            name = "Sartharion",
            instanceId = 755,
            uiMapId = 155
          },
          dungeonEncounter = {
            id = 1090,
            name = "Sartharion",
            mapId = 615
          }
        }
      },
      {
        id = 250,
        name = "Twilight Drake",
        icon = "interface/icons/ability_mount_drake_twilight.blp",
        itemId = 43954,
        spellId = 59571,
        source = {
          mapId = 615,
          uiMapIds = {
            155
          },
          allowedDifficultyIds = {
            4
          },
          note = "All 3 outer dragons must still be alive when Sartharion was pulled in order for this mount to drop.",
          journalEncounter = {
            id = 1616,
            name = "Sartharion",
            instanceId = 755,
            uiMapId = 155
          },
          dungeonEncounter = {
            id = 1090,
            name = "Sartharion",
            mapId = 615
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "The Obsidian Sanctum"
    },
    expansion = 2
  },
  {
    id = 9,
    mounts = {
      {
        id = 264,
        name = "Blue Proto-Drake",
        icon = "interface/icons/ability_mount_drake_proto.blp",
        itemId = 44151,
        spellId = 59996,
        source = {
          mapId = 575,
          uiMapIds = {
            137
          },
          allowedDifficultyIds = {
            2
          },
          journalEncounter = {
            id = 643,
            name = "Skadi the Ruthless",
            instanceId = 286,
            uiMapId = 137
          },
          dungeonEncounter = {
            id = 581,
            name = "Skadi the Ruthless",
            mapId = 575
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Utgarde Pinnacle"
    },
    expansion = 2
  },
  {
    id = 10,
    mounts = {
      {
        id = 304,
        name = "Mimiron's Head",
        icon = "interface/icons/inv_misc_enggizmos_03.blp",
        itemId = 45693,
        spellId = 63796,
        source = {
          mapId = 603,
          uiMapIds = {
            150
          },
          allowedDifficultyIds = {
            4
          },
          note = "Defeat Yogg-Saron without the assistance of any Keepers in order for this mount to drop.",
          journalEncounter = {
            id = 1649,
            name = "Yogg-Saron",
            instanceId = 759,
            uiMapId = 150
          },
          dungeonEncounter = {
            id = 1143,
            name = "Yogg-Saron",
            mapId = 603
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Ulduar"
    },
    expansion = 2
  },
  {
    id = 11,
    mounts = {
      {
        id = 425,
        name = "Flametalon of Alysrazor",
        icon = "interface/icons/ability_mount_fireravengodmount.blp",
        itemId = 71665,
        spellId = 101542,
        source = {
          mapId = 720,
          uiMapIds = {
            367
          },
          allowedDifficultyIds = {
            3,
            4,
            5,
            6
          },
          journalEncounter = {
            id = 194,
            name = "Alysrazor",
            instanceId = 78,
            uiMapId = 367
          },
          dungeonEncounter = {
            id = 1206,
            name = "Alysrazor",
            mapId = 720
          }
        }
      },
      {
        id = 415,
        name = "Pureblood Fire Hawk",
        icon = "interface/icons/inv_misc_orb_05.blp",
        itemId = 69224,
        spellId = 97493,
        source = {
          mapId = 720,
          uiMapIds = {
            369
          },
          allowedDifficultyIds = {
            3,
            4,
            5,
            6
          },
          journalEncounter = {
            id = 198,
            name = "Ragnaros",
            instanceId = 78,
            uiMapId = 369
          },
          dungeonEncounter = {
            id = 1203,
            name = "Ragnaros",
            mapId = 720
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Firelands"
    },
    expansion = 3
  },
  {
    id = 12,
    mounts = {
      {
        id = 248,
        name = "Bronze Drake",
        icon = "interface/icons/ability_mount_drake_bronze.blp",
        itemId = 43951,
        spellId = 59569,
        source = {
          mapId = 595,
          uiMapIds = {
            131
          },
          allowedDifficultyIds = {
            2
          },
          note = "In order for him to be available, you must complete the timed event in under 25 minutes.",
          specialEncounter = {
            name = "Infinite Corruptor"
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "The Culling of Stratholme"
    },
    expansion = 2
  },
  {
    id = 13,
    mounts = {
      {
        id = 445,
        name = "Experiment 12-B",
        icon = "interface/icons/ability_mount_drake_twilight.blp",
        itemId = 78919,
        spellId = 110039,
        source = {
          mapId = 967,
          uiMapIds = {
            409
          },
          allowedDifficultyIds = {
            3,
            4,
            5,
            6
          },
          journalEncounter = {
            id = 331,
            name = "Ultraxion",
            instanceId = 187,
            uiMapId = 409
          },
          dungeonEncounter = {
            id = 1297,
            name = "Ultraxion",
            mapId = 967
          }
        }
      },
      {
        id = 442,
        name = "Blazing Drake",
        icon = "interface/icons/ability_mount_drake_red.blp",
        itemId = 77067,
        spellId = 107842,
        source = {
          mapId = 967,
          uiMapIds = {
            415
          },
          allowedDifficultyIds = {
            3,
            4,
            5,
            6
          },
          journalEncounter = {
            id = 333,
            name = "Madness of Deathwing",
            instanceId = 187,
            uiMapId = 415
          },
          dungeonEncounter = {
            id = 1299,
            name = "Madness of Deathwing",
            mapId = 967
          }
        }
      },
      {
        id = 444,
        name = "Life-Binder's Handmaiden",
        icon = "interface/icons/ability_mount_drake_red.blp",
        itemId = 77069,
        spellId = 107845,
        source = {
          mapId = 967,
          uiMapIds = {
            415
          },
          allowedDifficultyIds = {
            5,
            6
          },
          journalEncounter = {
            id = 333,
            name = "Madness of Deathwing",
            instanceId = 187,
            uiMapId = 415
          },
          dungeonEncounter = {
            id = 1299,
            name = "Madness of Deathwing",
            mapId = 967
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Dragon Soul"
    },
    expansion = 3
  },
  {
    id = 14,
    mounts = {
      {
        id = 397,
        name = "Vitreous Stone Drake",
        icon = "interface/icons/inv_misc_stonedragonblue.blp",
        itemId = 63043,
        spellId = 88746,
        source = {
          mapId = 725,
          uiMapIds = {
            324
          },
          allowedDifficultyIds = {
            1,
            2
          },
          journalEncounter = {
            id = 111,
            name = "Slabhide",
            instanceId = 67,
            uiMapId = 324
          },
          dungeonEncounter = {
            id = 1059,
            name = "Slabhide",
            mapId = 725
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "The Stonecore"
    },
    expansion = 3
  },
  {
    id = 15,
    mounts = {
      {
        id = 185,
        name = "Raven Lord",
        icon = "interface/icons/inv-mount_raven_54.blp",
        itemId = 32768,
        spellId = 41252,
        source = {
          mapId = 556,
          uiMapIds = {
            259
          },
          allowedDifficultyIds = {
            2
          },
          journalEncounter = {
            id = 542,
            name = "Anzu",
            instanceId = 252,
            uiMapId = 259
          },
          dungeonEncounter = {
            id = 1904,
            name = "Anzu",
            mapId = 556
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Sethekk Halls"
    },
    expansion = 1
  },
  {
    id = 16,
    mounts = {
      {
        id = 183,
        name = "Ashes of Al'ar",
        icon = "interface/icons/inv_misc_summerfest_brazierorange.blp",
        itemId = 32458,
        spellId = 40192,
        source = {
          mapId = 550,
          uiMapIds = {
            334
          },
          allowedDifficultyIds = {
            4
          },
          journalEncounter = {
            id = 1576,
            name = "Kael'thas Sunstrider",
            instanceId = 749,
            uiMapId = 334
          },
          dungeonEncounter = {
            id = 733,
            name = "Kael'thas Sunstrider",
            mapId = 550
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "The Eye"
    },
    expansion = 1
  },
  {
    id = 17,
    mounts = {
      {
        id = 213,
        name = "Swift White Hawkstrider",
        icon = "interface/icons/ability_mount_cockatricemountelite_white.blp",
        itemId = 35513,
        spellId = 46628,
        source = {
          mapId = 585,
          uiMapIds = {
            348
          },
          allowedDifficultyIds = {
            2
          },
          journalEncounter = {
            id = 533,
            name = "Kael'thas Sunstrider",
            instanceId = 249,
            uiMapId = 348
          },
          dungeonEncounter = {
            id = 1894,
            name = "Kael'thas Sunstrider",
            mapId = 585
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Magisters' Terrace"
    },
    expansion = 1
  },
  {
    id = 18,
    mounts = {
      {
        id = 419,
        name = "Amani Battle Bear",
        icon = "interface/icons/ability_druid_challangingroar.blp",
        itemId = 69747,
        spellId = 98204,
        source = {
          mapId = 568,
          uiMapIds = {
            333
          },
          allowedDifficultyIds = {
            2
          },
          note = "In order for Kasha's Bag to drop, you must complete the timed event in under 45 minutes.",
          journalEncounter = {
            id = 189,
            name = "Halazzi",
            instanceId = 77,
            uiMapId = 333
          },
          dungeonEncounter = {
            id = 1192,
            name = "Halazzi",
            mapId = 568
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Zul'Aman"
    },
    expansion = 3
  },
  {
    id = 19,
    mounts = {
      {
        id = 69,
        name = "Rivendare's Deathcharger",
        icon = "interface/icons/ability_mount_undeadhorse.blp",
        itemId = 18063,
        spellId = 17481,
        source = {
          mapId = 329,
          uiMapIds = {
            318
          },
          allowedDifficultyIds = {
            1
          },
          journalEncounter = {
            id = 456,
            name = "Lord Aurius Rivendare",
            instanceId = 236,
            uiMapId = 318
          },
          dungeonEncounter = {
            id = 484,
            name = "Lord Aurius Rivendare",
            mapId = 329
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Stratholme"
    },
    expansion = 0
  },
  {
    id = 20,
    mounts = {
      {
        id = 168,
        name = "Fiery Warhorse",
        icon = "interface/icons/ability_mount_dreadsteed.blp",
        itemId = 30480,
        spellId = 36702,
        source = {
          mapId = 532,
          uiMapIds = {
            350
          },
          allowedDifficultyIds = {
            3
          },
          journalEncounter = {
            id = 1553,
            name = "Attumen the Huntsman",
            instanceId = 745,
            uiMapId = 350
          },
          dungeonEncounter = {
            id = 652,
            name = "Attumen the Huntsman",
            mapId = 532
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Karazhan"
    },
    expansion = 1
  },
  {
    id = 21,
    mounts = {
      {
        id = 411,
        name = "Swift Zulian Panther",
        icon = "interface/icons/ability_mount_blackpanther.blp",
        itemId = 68824,
        spellId = 96499,
        source = {
          mapId = 859,
          uiMapIds = {
            337
          },
          allowedDifficultyIds = {
            2
          },
          journalEncounter = {
            id = 181,
            name = "High Priestess Kilnara",
            instanceId = 76,
            uiMapId = 337
          },
          dungeonEncounter = {
            id = 1180,
            name = "High Priestess Kilnara",
            mapId = 859
          }
        }
      },
      {
        id = 410,
        name = "Armored Razzashi Raptor",
        icon = "interface/icons/ability_mount_raptor.blp",
        itemId = 68823,
        spellId = 96491,
        source = {
          mapId = 859,
          uiMapIds = {
            337
          },
          allowedDifficultyIds = {
            2
          },
          journalEncounter = {
            id = 176,
            name = "Bloodlord Mandokir",
            instanceId = 76,
            uiMapId = 337
          },
          dungeonEncounter = {
            id = 1179,
            name = "Bloodlord Mandokir",
            mapId = 859
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Zul'Gurub"
    },
    expansion = 3
  },
  {
    id = 22,
    mounts = {
      {
        id = 515,
        name = "Son of Galleon",
        icon = "interface/icons/inv_mushanbeastmount.blp",
        itemId = 89783,
        spellId = 130965,
        source = {
          mapId = 870,
          uiMapIds = {
            376
          },
          allowedDifficultyIds = {
            -1
          },
          bonusRoll = true,
          journalEncounter = {
            id = 725,
            name = "Salyis's Warband",
            instanceId = 322,
            uiMapId = 376
          }
        }
      }
    },
    source = {
      type = "WorldBoss",
      name = "Salyis's Warband"
    },
    expansion = 4
  },
  {
    id = 23,
    mounts = {
      {
        id = 473,
        name = "Heavenly Onyx Cloud Serpent",
        icon = "interface/icons/inv_pandarenserpentgodmount_black.blp",
        itemId = 87771,
        spellId = 127158,
        source = {
          mapId = 870,
          uiMapIds = {
            379
          },
          allowedDifficultyIds = {
            -1
          },
          bonusRoll = true,
          journalEncounter = {
            id = 691,
            name = "Sha of Anger",
            instanceId = 322,
            uiMapId = 379
          }
        }
      }
    },
    source = {
      type = "WorldBoss",
      name = "Sha of Anger"
    },
    expansion = 4
  },
  {
    id = 24,
    mounts = {
      {
        id = 533,
        name = "Cobalt Primordial Direhorn",
        icon = "interface/icons/ability_mount_triceratopsmount_blue.blp",
        itemId = 94228,
        spellId = 138423,
        source = {
          mapId = 870,
          uiMapIds = {
            507
          },
          allowedDifficultyIds = {
            -1
          },
          bonusRoll = true,
          journalEncounter = {
            id = 826,
            name = "Oondasta",
            instanceId = 322,
            uiMapId = 507
          }
        }
      }
    },
    source = {
      type = "WorldBoss",
      name = "Oondasta"
    },
    expansion = 4
  },
  {
    id = 25,
    mounts = {
      {
        id = 478,
        name = "Astral Cloud Serpent",
        icon = "interface/icons/inv_celestialserpentmount.blp",
        itemId = 87777,
        spellId = 127170,
        source = {
          mapId = 1008,
          uiMapIds = {
            473
          },
          allowedDifficultyIds = {
            3,
            4,
            5,
            6
          },
          journalEncounter = {
            id = 726,
            name = "Elegon",
            instanceId = 317,
            uiMapId = 473
          },
          dungeonEncounter = {
            id = 1500,
            name = "Elegon",
            mapId = 1008
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Mogu'shan Vaults"
    },
    expansion = 4
  },
  {
    id = 26,
    mounts = {
      {
        id = 542,
        name = "Thundering Cobalt Cloud Serpent",
        icon = "interface/icons/inv_pandarenserpentmount_lightning_blue.blp",
        itemId = 95057,
        spellId = 139442,
        source = {
          mapId = 1064,
          uiMapIds = {
            504
          },
          allowedDifficultyIds = {
            -1
          },
          bonusRoll = true,
          journalEncounter = {
            id = 814,
            name = "Nalak, The Storm Lord",
            instanceId = 322,
            uiMapId = 504
          }
        }
      }
    },
    source = {
      type = "WorldBoss",
      name = "Nalak, The Storm Lord"
    },
    expansion = 4
  },
  {
    id = 27,
    mounts = {
      {
        id = 531,
        name = "Spawn of Horridon",
        icon = "interface/icons/ability_mount_triceratopsmount.blp",
        itemId = 93666,
        spellId = 136471,
        source = {
          mapId = 1098,
          uiMapIds = {
            509
          },
          allowedDifficultyIds = {
            3,
            4,
            5,
            6
          },
          journalEncounter = {
            id = 819,
            name = "Horridon",
            instanceId = 362,
            uiMapId = 509
          },
          dungeonEncounter = {
            id = 1575,
            name = "Horridon",
            mapId = 1098
          }
        }
      },
      {
        id = 543,
        name = "Clutch of Ji-Kun",
        icon = "interface/icons/achievement_boss_ji-kun.blp",
        itemId = 95059,
        spellId = 139448,
        source = {
          mapId = 1098,
          uiMapIds = {
            511
          },
          allowedDifficultyIds = {
            3,
            4,
            5,
            6
          },
          journalEncounter = {
            id = 828,
            name = "Ji-Kun",
            instanceId = 362,
            uiMapId = 511
          },
          dungeonEncounter = {
            id = 1573,
            name = "Ji-Kun",
            mapId = 1098
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Throne of Thunder"
    },
    expansion = 4
  }
}

MRP.Steps = steps
