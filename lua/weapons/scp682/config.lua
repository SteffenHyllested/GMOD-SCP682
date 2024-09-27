Config = {}
_G.SCP682.Config = Config

Config.WALKSPEED = 240
Config.RUNSPEED = 360
Config.MAXHEALTH = 5000 -- Note: max health is multiplied by RF

Config.PRIMARY_HITBOX_RANGE = 60
Config.PRIMARY_HITBOX_OFFSET = 100 -- Note: this will offset the hitbox to the front of the player
Config.PRIMARY_COOLDOWN = 0.4
Config.PRIMARY_DAMAGE = 35

Config.SECONDARY_HITBOX_RANGE = 350
Config.SECONDARY_HITBOX_OFFSET = 0
Config.SECONDARY_COOLDOWN = 15
Config.SECONDARY_DAMAGE = 0

Config.ROAR_SELF_STUN = 2.5
Config.ROAR_TARGET_STUN = 5

Config.RF_KILL_REWARD = 0.05 -- Regenerative force gained on kill
Config.RF_DAMAGE_PENALTY_MULT = 0.001 -- How much Regenerative force is lost per damage taken
Config.RF_MAX = 3.00
Config.RF_MIN = 0.01
Config.RF_FREQ = 2 -- How frequently 682 regens
Config.RF_RATE = 0.015 -- How much (percentwise) 682 regens

Config.MODEL_SCALE_MIN = 0.7
Config.MODEL_SCALE_MAX = 1.2