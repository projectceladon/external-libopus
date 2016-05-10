LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

include $(LOCAL_PATH)/celt_sources.mk
include $(LOCAL_PATH)/opus_sources.mk
include $(LOCAL_PATH)/silk_sources.mk

LOCAL_MODULE    := libopus
OGG_DIR         := external/libogg
LOCAL_C_INCLUDES += $(LOCAL_PATH)/include $(LOCAL_PATH)/src $(LOCAL_PATH)/silk \
                    $(LOCAL_PATH)/celt $(LOCAL_PATH)/silk/fixed $(OGG_DIR)/include
LOCAL_SRC_FILES := $(CELT_SOURCES) $(SILK_SOURCES) $(SILK_SOURCES_FIXED) \
                   $(OPUS_SOURCES) $(OPUS_SOURCES_FLOAT) src/repacketizer_demo.c

LOCAL_CFLAGS        := -DNULL=0 -DSOCKLEN_T=socklen_t -DLOCALE_NOT_USED \
                       -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64 \
                       -Drestrict='' -D__EMX__ -DOPUS_BUILD -DFIXED_POINT \
                       -DUSE_ALLOCA -DHAVE_LRINT -DHAVE_LRINTF -O2 -fno-math-errno
LOCAL_CPPFLAGS      := -DBSD=1 -ffast-math -O2 -funroll-loops

ifneq ($(findstring $(TARGET_ARCH_ABI), armeabi-v7a arm64-v8a),)
LOCAL_SRC_FILES += $(CELT_SOURCES_ARM) $(CELT_SOURCES_ARM_NEON_INTR)
LOCAL_SRC_FILES += celt/arm/armopts_gnu.s.neon
LOCAL_SRC_FILES += $(subst .s,_gnu.s.neon,$(CELT_SOURCES_ARM_ASM))
LOCAL_ARM_NEON := true
LOCAL_CFLAGS += -DOPUS_ARM_ASM -DOPUS_ARM_INLINE_ASM -DOPUS_ARM_INLINE_EDSP \
                -DOPUS_ARM_INLINE_MEDIA -DOPUS_ARM_INLINE_NEON \
                -DOPUS_ARM_MAY_HAVE_NEON -DOPUS_ARM_MAY_HAVE_MEDIA \
                -DOPUS_ARM_MAY_HAVE_EDSP -DOPUS_ARM_MAY_HAVE_NEON_INTR \
                -DOPUS_HAVE_RTCD -DOPUS_ARM_PRESUME_EDSP \
                -DOPUS_ARM_PRESUME_MEDIA -DOPUS_ARM_PRESUME_NEON
endif

ifeq ($(ARCH_X86_HAVE_SSSE3),true)
LOCAL_CFLAGS += -DOPUS_X86_MAY_HAVE_SSE -DOPUS_X86_PRESUME_SSE \
                -DOPUS_X86_MAY_HAVE_SSE2 -DOPUS_X86_PRESUME_SSE2
LOCAL_SRC_FILES += $(CELT_SOURCES_SSE) $(CELT_SOURCES_SSE2)
endif

ifeq ($(ARCH_X86_HAVE_SSE4_1),true)
LOCAL_CFLAGS += -DOPUS_X86_MAY_HAVE_SSE4_1 -DOPUS_X86_PRESUME_SSE4_1
LOCAL_SRC_FILES += $(CELT_SOURCES_SSE4_1) \
                   $(SILK_SOURCES_SSE4_1) $(SILK_SOURCES_FIXED_SSE4_1)
endif

LOCAL_STATIC_LIBRARIES := libogg

include $(BUILD_SHARED_LIBRARY)
