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
            2,
            24
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
            id = 2029,
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
            14,
            33
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
            14,
            15,
            33
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
            14,
            15,
            33
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
            2,
            24
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
            2,
            24
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
        itemId = 13335,
        spellId = 17481,
        source = {
          mapId = 329,
          uiMapIds = {
            318
          },
          allowedDifficultyIds = {
            1,
            24
          },
          journalEncounter = {
            id = 456,
            name = "Lord Aurius Rivendare",
            instanceId = 1292,
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
        id = 875,
        name = "Midnight",
        icon = "interface/icons/inv_skeletalwarhorse_black.blp",
        itemId = 142236,
        spellId = 229499,
        source = {
          mapId = 1651,
          uiMapIds = {
            809
          },
          allowedDifficultyIds = {
            23
          },
          journalEncounter = {
            id = 1835,
            name = "Attumen the Huntsman",
            instanceId = 860,
            uiMapId = 809
          },
          dungeonEncounter = {
            id = 1960,
            name = "Attumen the Huntsman",
            mapId = 1651
          }
        }
      },
      {
        id = 883,
        name = "Smoldering Ember Wyrm",
        icon = "interface/icons/inv_nightbane2mount.blp",
        itemId = 142552,
        spellId = 231428,
        source = {
          mapId = 1651,
          uiMapIds = {
            814
          },
          allowedDifficultyIds = {
            23
          },
          note = "Upon opening the door after zoning into Karazhan, the following emote happens: \"The strange chill of a dark presence winds through the air.\" This starts the timer for the first crystal.\nYou have a STRICT timing to make it to Opera, kill Opera and click the first Soul Fragment. You have 8 minutes from the moment you zone in to click the first crystal.\nFrom there on each Soul Fragment you click add a bit of time to your timer. But its very very tight.\nAfter the first crystal you will gain a buff,  Medivh's Echo, with a 6min duration. This is now your timer. As you click crystals, it will add a stacking buff and 5 minutes to the time you had left on your buff.\nIf you fail the speed run, you will get an emote notification: \"The air grows slightly warmer\".\nThe Soul Fragments are located as follows: 1 in the audience from Opera, 1 before Maiden (you don't need to kill her), 1 after you kill Moroes, 1 in the Spider Room (then you click the portal to the stairway), 1 after you kill Curator.\nIf you click all the Soul Fragment within the allotted time, run back to Nightbane's room after killing Curator.\nUpon clicking the final crystal in time, your timer buff will change to  Medivh's Presence and you will have 5 minutes to go speak with Medivh and summon Nightbane. When you speak to Medivh you get the One Night in Karazhan One Night in Karazhan achievement.\nThe original Roleplay upon summoning Nightbane will then play, and then you will be able to fight Nightbane.\nOnce you speak to Medivh and Nightbane is summoned, you are able to wipe without worry. He will still be there and shout at you as he continuously slays you.",
          dungeonEncounter = {
            id = 2031,
            name = "Nightbane",
            mapId = 1651
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Return to Karazhan"
    },
    expansion = 6
  },
  {
    id = 22,
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
    id = 23,
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
    id = 24,
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
    id = 25,
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
    id = 26,
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
            6,
            7
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
    id = 27,
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
    id = 28,
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
  },
  {
    id = 29,
    mounts = {
      {
        id = 559,
        name = "Kor'kron Juggernaut",
        icon = "interface/icons/inv_mount_hordescorpiong.blp",
        itemId = 104253,
        spellId = 148417,
        source = {
          mapId = 1136,
          uiMapIds = {
            567
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 869,
            name = "Garrosh Hellscream",
            instanceId = 369,
            uiMapId = 567
          },
          dungeonEncounter = {
            id = 1623,
            name = "Garrosh Hellscream",
            mapId = 1136
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Siege of Orgrimmar"
    },
    expansion = 4
  },
  {
    id = 30,
    mounts = {
      {
        id = 634,
        name = "Solar Spirehawk",
        icon = "interface/icons/inv_helm_suncrown_d_01.blp",
        itemId = 116771,
        spellId = 171828,
        source = {
          mapId = 1116,
          uiMapIds = {
            542
          },
          allowedDifficultyIds = {
            -1
          },
          bonusRoll = false,
          journalEncounter = {
            id = 1262,
            name = "Rukhmar",
            instanceId = 557,
            uiMapId = 542
          }
        }
      }
    },
    source = {
      type = "WorldBoss",
      name = "Rukhmar"
    },
    expansion = 5
  },
  {
    id = 31,
    mounts = {
      {
        id = 751,
        name = "Felsteel Annihilator",
        icon = "interface/icons/ability_mount_felreavermount.blp",
        itemId = 123890,
        spellId = 182912,
        source = {
          mapId = 1448,
          uiMapIds = {
            670
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 1438,
            name = "Archimonde",
            instanceId = 669,
            uiMapId = 670
          },
          dungeonEncounter = {
            id = 1799,
            name = "Archimonde",
            mapId = 1448
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Hellfire Citadel"
    },
    expansion = 5
  },
  {
    id = 32,
    mounts = {
      {
        id = 613,
        name = "Ironhoof Destroyer",
        icon = "interface/icons/inv_ironhordeclefthoof.blp",
        itemId = 116660,
        spellId = 171621,
        source = {
          mapId = 1205,
          uiMapIds = {
            600
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 959,
            name = "Blackhand",
            instanceId = 457,
            uiMapId = 600
          },
          dungeonEncounter = {
            id = 1704,
            name = "Blackhand",
            mapId = 1205
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Blackrock Foundry"
    },
    expansion = 5
  },
  {
    id = 33,
    mounts = {
      {
        id = 791,
        name = "Felblaze Infernal",
        icon = "interface/icons/inv_infernalmountgreen.blp",
        itemId = 137574,
        spellId = 213134,
        source = {
          mapId = 1530,
          uiMapIds = {
            772
          },
          allowedDifficultyIds = {
            14,
            15,
            16
          },
          journalEncounter = {
            id = 1737,
            name = "Gul'dan",
            instanceId = 786,
            uiMapId = 772
          },
          dungeonEncounter = {
            id = 1866,
            name = "Gul'dan",
            mapId = 1530
          }
        }
      },
      {
        id = 633,
        name = "Hellfire Infernal",
        icon = "interface/icons/inv_infernalmountred.blp",
        itemId = 116770,
        spellId = 171827,
        source = {
          mapId = 1530,
          uiMapIds = {
            772
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 1737,
            name = "Gul'dan",
            instanceId = 786,
            uiMapId = 772
          },
          dungeonEncounter = {
            id = 1866,
            name = "Gul'dan",
            mapId = 1530
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "The Nighthold"
    },
    expansion = 6
  },
  {
    id = 34,
    mounts = {
      {
        id = 899,
        name = "Abyss Worm",
        icon = "interface/icons/inv_serpentmount_green.blp",
        itemId = 143643,
        spellId = 232519,
        source = {
          mapId = 1676,
          uiMapIds = {
            851
          },
          allowedDifficultyIds = {
            14,
            15,
            16,
            17
          },
          journalEncounter = {
            id = 1861,
            name = "Mistress Sassz'ine",
            instanceId = 875,
            uiMapId = 851
          },
          dungeonEncounter = {
            id = 2037,
            name = "Mistress Sassz'ine",
            mapId = 1676
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Tomb of Sargeras"
    },
    expansion = 6
  },
  {
    id = 35,
    mounts = {
      {
        id = 971,
        name = "Antoran Charhound",
        icon = "interface/icons/inv_felhound3_shadow_fire.blp",
        itemId = 152816,
        spellId = 253088,
        source = {
          mapId = 1712,
          uiMapIds = {
            909
          },
          allowedDifficultyIds = {
            14,
            15,
            16,
            17
          },
          journalEncounter = {
            id = 1987,
            name = "Felhounds of Sargeras",
            instanceId = 946,
            uiMapId = 909
          },
          dungeonEncounter = {
            id = 2074,
            name = "Felhounds of Sargeras",
            mapId = 1712
          }
        }
      },
      {
        id = 954,
        name = "Shackled Ur'zul",
        icon = "interface/icons/inv_soulhoundmount_blue.blp",
        itemId = 152789,
        spellId = 243651,
        source = {
          mapId = 1712,
          uiMapIds = {
            918
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 2031,
            name = "Argus the Unmaker",
            instanceId = 946,
            uiMapId = 918
          },
          dungeonEncounter = {
            id = 2092,
            name = "Argus the Unmaker",
            mapId = 1712
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Antorus, the Burning Throne"
    },
    expansion = 6
  },
  {
    id = 36,
    mounts = {
      {
        id = 1217,
        name = "G.M.O.D.",
        icon = "interface/icons/achievement_dungeon_coinoperatedcrowdpummeler.blp",
        itemId = 166518,
        spellId = 289083,
        source = {
          mapId = 2070,
          uiMapIds = {
            1352,
            1364
          },
          allowedDifficultyIds = {
            14,
            15,
            16
          },
          journalEncounter = {
            id = 2334,
            name = "High Tinker Mekkatorque",
            instanceId = 1176,
            uiMapId = 1352
          },
          dungeonEncounter = {
            id = 2276,
            name = "Mekkatorque",
            mapId = 2070
          }
        }
      },
      {
        id = 1217,
        name = "G.M.O.D.",
        icon = "interface/icons/achievement_dungeon_coinoperatedcrowdpummeler.blp",
        itemId = 166518,
        spellId = 289083,
        source = {
          mapId = 2070,
          uiMapIds = {
            1352,
            1364
          },
          allowedDifficultyIds = {
            17
          },
          journalEncounter = {
            id = 2343,
            name = "Lady Jaina Proudmoore",
            instanceId = 1176,
            uiMapId = 1364
          },
          dungeonEncounter = {
            id = 2281,
            name = "Lady Jaina Proudmoore",
            mapId = 2070
          }
        }
      },
      {
        id = 1219,
        name = "Glacial Tidestorm",
        icon = "interface/icons/spell_frost_summonwaterelemental_2.blp",
        itemId = 166705,
        spellId = 289555,
        source = {
          mapId = 2070,
          uiMapIds = {
            1364
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 2343,
            name = "Lady Jaina Proudmoore",
            instanceId = 1176,
            uiMapId = 1364
          },
          dungeonEncounter = {
            id = 2281,
            name = "Lady Jaina Proudmoore",
            mapId = 2070
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Battle of Dazar'alor"
    },
    expansion = 7
  },
  {
    id = 37,
    mounts = {
      {
        id = 995,
        name = "Sharkbait",
        icon = "interface/icons/inv_misc_food_wheat_02.blp",
        itemId = 159842,
        spellId = 254813,
        source = {
          mapId = 1754,
          uiMapIds = {
            936
          },
          allowedDifficultyIds = {
            23
          },
          journalEncounter = {
            id = 2095,
            name = "Harlan Sweete",
            instanceId = 1001,
            uiMapId = 936
          },
          dungeonEncounter = {
            id = 2096,
            name = "Lord Harlan Sweete",
            mapId = 1754
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Freehold"
    },
    expansion = 7
  },
  {
    id = 38,
    mounts = {
      {
        id = 1040,
        name = "Tomb Stalker",
        icon = "interface/icons/inv_armoredraptorundead.blp",
        itemId = 159921,
        spellId = 266058,
        source = {
          mapId = 1762,
          uiMapIds = {
            1004
          },
          allowedDifficultyIds = {
            23
          },
          journalEncounter = {
            id = 2172,
            name = "Dazar, The First King",
            instanceId = 1041,
            uiMapId = 1004
          },
          dungeonEncounter = {
            id = 2143,
            name = "King Dazar",
            mapId = 1762
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "King's Rest"
    },
    expansion = 7
  },
  {
    id = 39,
    mounts = {
      {
        id = 1053,
        name = "Underrot Crawg",
        icon = "interface/icons/inv_archaeology_ogres_chimera_riding_harness.blp",
        itemId = 160829,
        spellId = 273541,
        source = {
          mapId = 1841,
          uiMapIds = {
            1042
          },
          allowedDifficultyIds = {
            23
          },
          journalEncounter = {
            id = 2158,
            name = "Unbound Abomination",
            instanceId = 1022,
            uiMapId = 1042
          },
          dungeonEncounter = {
            id = 2123,
            name = "Unbound Abomination",
            mapId = 1841
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "The Underrot"
    },
    expansion = 7
  },
  {
    id = 40,
    mounts = {
      {
        id = 1252,
        name = "Mechagon Peacekeeper",
        icon = "interface/icons/inv_mechagonspidertank_brass.blp",
        itemId = 168826,
        spellId = 299158,
        source = {
          mapId = 2097,
          uiMapIds = {
            1490
          },
          allowedDifficultyIds = {
            23
          },
          journalEncounter = {
            id = 2355,
            name = "HK-8 Aerial Oppression Unit",
            instanceId = 1178,
            uiMapId = 1490
          },
          dungeonEncounter = {
            id = 2291,
            name = "HK-8 Aerial Oppression Unit",
            mapId = 2097
          }
        }
      },
      {
        id = 1227,
        name = "Aerial Unit R-21/X",
        icon = "interface/icons/inv_hunterkillershipyellow.blp",
        itemId = 168830,
        spellId = 290718,
        source = {
          mapId = 2097,
          uiMapIds = {
            1497
          },
          allowedDifficultyIds = {
            23
          },
          note = "In order for the mount to drop, you must complete the dungeon on Hard Mode.",
          journalEncounter = {
            id = 2331,
            name = "King Mechagon",
            instanceId = 1178,
            uiMapId = 1497
          },
          dungeonEncounter = {
            id = 2260,
            name = "King Mechagon",
            mapId = 2097
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Operation: Mechagon"
    },
    expansion = 7
  },
  {
    id = 41,
    mounts = {
      {
        id = 1293,
        name = "Ny'alotha Allseer",
        icon = "interface/icons/inv_eyeballjellyfishmount.blp",
        itemId = 174872,
        spellId = 308814,
        source = {
          mapId = 2217,
          uiMapIds = {
            1597
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 2375,
            name = "N'Zoth the Corruptor",
            instanceId = 1180,
            uiMapId = 1597
          },
          dungeonEncounter = {
            id = 2344,
            name = "N'Zoth the Corruptor",
            mapId = 2217
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Ny'alotha the Waking City"
    },
    expansion = 7
  },
  {
    id = 42,
    mounts = {
      {
        id = 1406,
        name = "Marrowfang",
        icon = "interface/icons/inv_maldraxxusflyermount_red.blp",
        itemId = 181819,
        spellId = 336036,
        source = {
          mapId = 2286,
          uiMapIds = {
            1668
          },
          allowedDifficultyIds = {
            23
          },
          journalEncounter = {
            id = 2396,
            name = "Nalthor the Rimebinder",
            instanceId = 1182,
            uiMapId = 1668
          },
          dungeonEncounter = {
            id = 2390,
            name = "Nalthor the Rimebinder",
            mapId = 2286
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "The Necrotic Wake"
    },
    expansion = 8
  },
  {
    id = 43,
    mounts = {
      {
        id = 1481,
        name = "Cartel Master's Gearglider",
        icon = "interface/icons/inv_brokermount_dark.blp",
        itemId = 186638,
        spellId = 353263,
        source = {
          mapId = 2441,
          uiMapIds = {
            1989
          },
          allowedDifficultyIds = {
            2,
            23
          },
          journalEncounter = {
            id = 2455,
            name = "So'leah",
            instanceId = 1194,
            uiMapId = 1989
          },
          dungeonEncounter = {
            id = 2442,
            name = "So'leah",
            mapId = 2441
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Tazavesh, the Veiled Market"
    },
    expansion = 8
  },
  {
    id = 44,
    mounts = {
      {
        id = 1500,
        name = "Sanctum Gloomcharger",
        icon = "interface/icons/ability_mount_mawhorsespikes_purple.blp",
        itemId = 186656,
        spellId = 354351,
        source = {
          mapId = 2450,
          uiMapIds = {
            1999
          },
          allowedDifficultyIds = {
            14,
            15,
            16,
            17
          },
          journalEncounter = {
            id = 2439,
            name = "The Nine",
            instanceId = 1193,
            uiMapId = 1999
          },
          dungeonEncounter = {
            id = 2429,
            name = "The Nine",
            mapId = 2450
          }
        }
      },
      {
        id = 1471,
        name = "Vengeance",
        icon = "interface/icons/inv_dragonhawkmountshadowlands.blp",
        itemId = 186642,
        spellId = 351195,
        source = {
          mapId = 2450,
          uiMapIds = {
            2002
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 2441,
            name = "Sylvanas Windrunner",
            instanceId = 1193,
            uiMapId = 2002
          },
          dungeonEncounter = {
            id = 2435,
            name = "Sylvanas Windrunner",
            mapId = 2450
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Sanctum of Domination"
    },
    expansion = 8
  },
  {
    id = 45,
    mounts = {
      {
        id = 1587,
        name = "Zereth Overseer",
        icon = "interface/icons/inv_progenitorbotminemount.blp",
        itemId = 190768,
        spellId = 368158,
        source = {
          mapId = 2481,
          uiMapIds = {
            2051
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 2464,
            name = "The Jailer",
            instanceId = 1195,
            uiMapId = 2051
          },
          dungeonEncounter = {
            id = 2537,
            name = "The Jailer",
            mapId = 2481
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Sepulcher of the First Ones"
    },
    expansion = 8
  },
  {
    id = 46,
    mounts = {
      {
        id = 69,
        name = "Rivendare's Deathcharger",
        icon = "interface/icons/ability_mount_undeadhorse.blp",
        itemId = 13335,
        spellId = 17481,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 185,
        name = "Raven Lord",
        icon = "interface/icons/inv-mount_raven_54.blp",
        itemId = 32768,
        spellId = 41252,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 213,
        name = "Swift White Hawkstrider",
        icon = "interface/icons/ability_mount_cockatricemountelite_white.blp",
        itemId = 35513,
        spellId = 46628,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 264,
        name = "Blue Proto-Drake",
        icon = "interface/icons/ability_mount_drake_proto.blp",
        itemId = 44151,
        spellId = 59996,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 395,
        name = "Drake of the North Wind",
        icon = "interface/icons/inv_misc_stormdragonpale.blp",
        itemId = 63040,
        spellId = 88742,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 397,
        name = "Vitreous Stone Drake",
        icon = "interface/icons/inv_misc_stonedragonblue.blp",
        itemId = 63043,
        spellId = 88746,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
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
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 411,
        name = "Swift Zulian Panther",
        icon = "interface/icons/ability_mount_blackpanther.blp",
        itemId = 68824,
        spellId = 96499,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 781,
        name = "Infinite Timereaver",
        icon = "interface/icons/achievement_boss_infinitecorruptor.blp",
        itemId = 133543,
        spellId = 201098,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 875,
        name = "Midnight",
        icon = "interface/icons/inv_skeletalwarhorse_black.blp",
        itemId = 142236,
        spellId = 229499,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 995,
        name = "Sharkbait",
        icon = "interface/icons/inv_misc_food_wheat_02.blp",
        itemId = 159842,
        spellId = 254813,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 1040,
        name = "Tomb Stalker",
        icon = "interface/icons/inv_armoredraptorundead.blp",
        itemId = 159921,
        spellId = 266058,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 1053,
        name = "Underrot Crawg",
        icon = "interface/icons/inv_archaeology_ogres_chimera_riding_harness.blp",
        itemId = 160829,
        spellId = 273541,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 1252,
        name = "Mechagon Peacekeeper",
        icon = "interface/icons/inv_mechagonspidertank_brass.blp",
        itemId = 168826,
        spellId = 299158,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 1406,
        name = "Marrowfang",
        icon = "interface/icons/inv_maldraxxusflyermount_red.blp",
        itemId = 181819,
        spellId = 336036,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      },
      {
        id = 1481,
        name = "Cartel Master's Gearglider",
        icon = "interface/icons/inv_brokermount_dark.blp",
        itemId = 186638,
        spellId = 353263,
        source = {
          mapId = 2579,
          uiMapIds = {
            2194
          },
          allowedDifficultyIds = {
            23
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:208216::::::::80:::::\124h[Reins of the Quantum Courser]\124h\124r.",
          journalEncounter = {
            id = 2538,
            name = "Chrono-Lord Deios",
            instanceId = 1209,
            uiMapId = 2194
          },
          dungeonEncounter = {
            id = 2673,
            name = "Chrono-Lord Deios",
            mapId = 2579
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Dawn of the Infinite"
    },
    expansion = 9
  },
  {
    id = 47,
    mounts = {
      {
        id = 1818,
        name = "Anu'relos, Flame's Guidance",
        icon = "interface/icons/inv_dreamowl_firemount.blp",
        itemId = 210061,
        spellId = 424484,
        source = {
          mapId = 2549,
          uiMapIds = {
            2238
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 2519,
            name = "Fyrakk the Blazing",
            instanceId = 1207,
            uiMapId = 2238
          },
          dungeonEncounter = {
            id = 2677,
            name = "Fyrakk the Blazing",
            mapId = 2549
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Amirdrassil, the Dream's Hope"
    },
    expansion = 9
  },
  {
    id = 48,
    mounts = {
      {
        id = 2204,
        name = "Wick",
        icon = "interface/icons/inv_misc_rope_01.blp",
        itemId = 225548,
        spellId = 449264,
        source = {
          mapId = 2651,
          uiMapIds = {
            2303
          },
          allowedDifficultyIds = {
            23,
            8
          },
          journalEncounter = {
            id = 2561,
            name = "The Darkness",
            instanceId = 1210,
            uiMapId = 2303
          },
          dungeonEncounter = {
            id = 2788,
            name = "The Darkness",
            mapId = 2651
          }
        }
      }
    },
    source = {
      type = "Dungeon",
      name = "Darkflame Cleft"
    },
    expansion = 10
  },
  {
    id = 49,
    mounts = {
      {
        id = 2219,
        name = "Sureki Skyrazor",
        icon = "interface/icons/inv_nerubianwarbeastmount_blue.blp",
        itemId = 224147,
        spellId = 451486,
        source = {
          mapId = 2657,
          uiMapIds = {
            2295
          },
          allowedDifficultyIds = {
            14,
            15,
            16,
            17
          },
          journalEncounter = {
            id = 2602,
            name = "Queen Ansurek",
            instanceId = 1273,
            uiMapId = 2295
          },
          dungeonEncounter = {
            id = 2922,
            name = "Queen Ansurek",
            mapId = 2657
          }
        }
      },
      {
        id = 2223,
        name = "Ascendant Skyrazor",
        icon = "interface/icons/inv_nerubianwarbeastmount_white.blp",
        itemId = 224151,
        spellId = 451491,
        source = {
          mapId = 2657,
          uiMapIds = {
            2295
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 2602,
            name = "Queen Ansurek",
            instanceId = 1273,
            uiMapId = 2295
          },
          dungeonEncounter = {
            id = 2922,
            name = "Queen Ansurek",
            mapId = 2657
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Nerub-ar Palace"
    },
    expansion = 10
  },
  {
    id = 50,
    mounts = {
      {
        id = 2507,
        name = "Prototype A.S.M.R.",
        icon = "interface/icons/inv_goblinflyingmachine.blp",
        itemId = 236960,
        spellId = 1221155,
        source = {
          mapId = 2769,
          uiMapIds = {
            2409
          },
          allowedDifficultyIds = {
            14,
            15,
            16,
            17
          },
          journalEncounter = {
            id = 2646,
            name = "Chrome King Gallywix",
            instanceId = 1296,
            uiMapId = 2409
          },
          dungeonEncounter = {
            id = 3016,
            name = "Chrome King Gallywix",
            mapId = 2769
          }
        }
      },
      {
        id = 2487,
        name = "The Big G",
        icon = "interface/icons/inv_gallywixmechmount.blp",
        itemId = 235626,
        spellId = 1217760,
        source = {
          mapId = 2769,
          uiMapIds = {
            2409
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 2646,
            name = "Chrome King Gallywix",
            instanceId = 1296,
            uiMapId = 2409
          },
          dungeonEncounter = {
            id = 3016,
            name = "Chrome King Gallywix",
            mapId = 2769
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Liberation of Undermine"
    },
    expansion = 10
  },
  {
    id = 51,
    mounts = {
      {
        id = 2606,
        name = "Royal Voidwing",
        icon = "interface/icons/inv_voiddragonmount2ethereal_king.blp",
        itemId = 246445,
        spellId = 1242272,
        source = {
          mapId = 2810,
          uiMapIds = {
            2467
          },
          allowedDifficultyIds = {
            15,
            16
          },
          note = "This mount is only obtainable from \124cffa335ee\124Hitem:246446::::::::80:::::\124h[Mark of the Twilight Oath]\124h\124r, which starts the quest 'A Twilight Oath's End'. This quest is only available until the release of Midnight.",
          journalEncounter = {
            id = 2691,
            name = "Dimensius, the All-Devouring",
            instanceId = 1302,
            uiMapId = 2467
          },
          dungeonEncounter = {
            id = 3135,
            name = "Dimensius, the All-Devouring",
            mapId = 2810
          }
        }
      },
      {
        id = 2569,
        name = "Unbound Star-Eater",
        icon = "interface/icons/inv_cosmicdragonmount.blp",
        itemId = 243061,
        spellId = 1234573,
        source = {
          mapId = 2810,
          uiMapIds = {
            2467
          },
          allowedDifficultyIds = {
            16
          },
          journalEncounter = {
            id = 2691,
            name = "Dimensius, the All-Devouring",
            instanceId = 1302,
            uiMapId = 2467
          },
          dungeonEncounter = {
            id = 3135,
            name = "Dimensius, the All-Devouring",
            mapId = 2810
          }
        }
      }
    },
    source = {
      type = "Raid",
      name = "Manaforge Omega"
    },
    expansion = 10
  }
}

MRP.Steps = steps
