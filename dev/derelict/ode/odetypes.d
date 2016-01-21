﻿/*
 * Copyright (c) 2004-2009 Derelict Developers
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * * Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *
 * * Neither the names 'Derelict', 'DerelictODE', nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
module derelict.ode.odetypes;

private
{
    version(Tango)
    {
        import tango.stdc.math;
        import tango.stdc.stdarg;
        
        const real PI         = 0x1.921fb54442d1846ap+1L;
        const real SQRT1_2    = 0.70710678118654752440L;
    }
	
    else
    {
        import std.math;
        import std.stdarg;
    }
}

// odeconfig.h
alias int int32;
alias uint uint32;
alias short int16;
alias ushort uint16;
alias byte int8;
alias ubyte uint8;

// common.h
version(DerelictODE_DoublePrecision)
{
    alias double dReal;
}
else
{
    alias float dReal;
}

alias PI M_PI;
alias SQRT1_2 M_SQRT1_2;

version(DerelictOde_TriMesh_16Bit_Indices)
{
    alias uint16 dTriIndex;
}
else
{
    alias uint32 dTriIndex;
}

int dPAD(int a)
{
    return (a > 1) ? (((a - 1)|3)+1) : a;
}

typedef dReal dVector3[4];
typedef dReal dVector4[4];
typedef dReal dMatrix3[4*3];
typedef dReal dMatrix4[4*4];
typedef dReal dMatrix6[8*6];
typedef dReal dQuaternion[4];

dReal dRecip(dReal x)
{
    return 1.0/x;
}

dReal dRecipSqrt(dReal x)
{
    return 1.0/sqrt(x);
}

dReal dFMod(dReal a, dReal b)
{
    version(Tango)
    {
        return modff(a, &b);
    }
    else
    {
        real c;
        return modf(a, c);
    }
}

alias sqrt dSqrt;
alias sin dSin;
alias cos dCos;
alias fabs dFabs;
alias atan2 dAtan2;
alias isnan dIsNan;
alias copysign dCopySign;

struct dxWorld {};
struct dxSpace {};
struct dxBody {};
struct dxGeom {};
struct dxJoint {};
struct dxJointNode {};
struct dxJointGroup {};

alias dxWorld* dWorldID;
alias dxSpace* dSpaceID;
alias dxBody* dBodyID;
alias dxGeom* dGeomID;
alias dxJoint* dJointID;
alias dxJointGroup* dJointGroupID;

enum
{
    d_ERR_UNKNOWN,
    d_ERR_IASSERT,
    d_ERR_UASSERT,
    d_ERR_LCP
}

alias int dJointType;
enum
{
    dJointTypeNone,
    dJointTypeBall,
    dJointTypeHinge,
    dJointTypeSlider,
    dJointTypeContact,
    dJointTypeUniversal,
    dJointTypeHinge2,
    dJointTypeFixed,
    dJointTypeNull,
    dJointTypeAMotor,
    dJointTypeLMotor,
    dJointTypePlane2D,
    dJointTypePR,
    dJointTypePU,
    dJointTypePiston,
}

enum
{
    dParamLoStop = 0,
    dParamHiStop,
    dParamVel,
    dParamFMax,
    dParamFudgeFactor,
    dParamBounce,
    dParamCFM,
    dParamStopERP,
    dParamStopCFM,
    dParamSuspensionERP,
    dParamSuspensionCFM,
    dParamERP,
    dParamsInGroup,
    dParamLoStop1 = 0x000,
    dParamHiStop1,
    dParamVel1,
    dParamFMax1,
    dParamFudgeFactor1,
    dParamBounce1,
    dParamCFM1,
    dParamStopERP1,
    dParamStopCFM1,
    dParamSuspensionERP1,
    dParamSuspensionCFM1,
    dParamERP1,
    dParamLoStop2 = 0x100,
    dParamHiStop2,
    dParamVel2,
    dParamFMax2,
    dParamFudgeFactor2,
    dParamBounce2,
    dParamCFM2,
    dParamStopERP2,
    dParamStopCFM2,
    dParamSuspensionERP2,
    dParamSuspensionCFM2,
    dParamERP2,
    dParamLoStop3 = 0x200,
    dParamHiStop3,
    dParamVel3,
    dParamFMax3,
    dParamFudgeFactor3,
    dParamBounce3,
    dParamCFM3,
    dParamStopERP3,
    dParamStopCFM3,
    dParamSuspensionERP3,
    dParamSuspensionCFM3,
    dParamERP3,
    dParamGroup = 0x100
}

enum
{
    dAMotorUser,
    dAMotorEuler,
}

struct dJointFeedback
{
    dVector3 f1;
    dVector3 t1;
    dVector3 f2;
    dVector3 t2;
}

// collision.h
enum
{
    CONTACTS_UNIMPORTANT = 0x80000000
}

enum
{
    dMaxUserClasses = 4
}

enum
{
    dSphereClass = 0,
    dBoxClass,
    dCapsuleClass,
    dCylinderClass,
    dPlaneClass,
    dRayClass,
    dConvexClass,
    dGeomTransformClass,
    dTriMeshClass,
    dHeightFieldClass,
    dFirstSpaceClass,
    dSimpleSpaceClass = dFirstSpaceClass,
    dHashSpaceClass,
    dSweepAndPruneClass,
    dQuadTreeClass,
    dLastSpaceClass = dQuadTreeClass,
    dFirstUserClass,
    dLastUserClass = dFirstUserClass + dMaxUserClasses - 1,
    dGeomNumClasses
}

alias dCapsuleClass dCCapsuleClass;

struct dxHeightfieldData;
alias dxHeightfieldData* dHeightfieldDataID;

extern(C)
{
    alias dReal function(void*, int, int) dHeightfieldGetHeight;
    alias void function(dGeomID, dReal[6]) dGetAABBFn;
    alias int function(dGeomID, dGeomID, int, dContactGeom*, int) dColliderFn;
    alias dColliderFn function(int) dGetColliderFnFn;
    alias void function(dGeomID) dGeomDtorFn;
    alias int function(dGeomID, dGeomID, dReal[6]) dAABBTestFn;
}


struct dGeomClass
{
    int bytes;
    dGetColliderFnFn collider;
    dGetAABBFn aabb;
    dAABBTestFn aabb_test;
    dGeomDtorFn dtor;
}

// collision_space.h
alias extern(C) void function(void*, dGeomID, dGeomID) dNearCallback;

enum
{
    dSAP_AXES_XYZ = ((0)|(1<<2)|(2<<4)),
    dSAP_AXES_XZY = ((0)|(2<<2)|(1<<4)),
    dSAP_AXES_YXZ = ((1)|(0<<2)|(2<<4)),
    dSAP_AXES_YZX = ((1)|(2<<2)|(0<<4)),
    dSAP_AXES_ZXY = ((2)|(0<<2)|(1<<4)),
    dSAP_AXES_ZYX = ((2)|(1<<2)|(0<<4))
}

// collision_trimesh.h
struct dxTriMeshData {}
alias dxTriMeshData* dTriMeshDataID;

enum { TRIMESH_FACE_NORMALS }

extern(C)
{
    alias int function(dGeomID, dGeomID, int) dTriCallback;
    alias void function(dGeomID, dGeomID, in int*, int) dTriArrayCallback;
    alias int function(dGeomID, dGeomID, int, dReal, dReal) dTriRayCallback;
    alias int function(dGeomID, int, int) dTriTriMergeCallback;
}

// contact.h
enum
{
    dContactMu2 = 0x001,
    dContactFDir1 = 0x002,
    dContactBounce = 0x004,
    dContactSoftERP = 0x008,
    dContactSoftCFM = 0x010,
    dContactMotion1 = 0x020,
    dContactMotion2 = 0x040,
    dContactMotionN = 0x080,
    dContactSlip1 = 0x100,
    dContactSlip2 = 0x200,

    dContactApprox0 = 0x0000,
    dContactApprox1_1 = 0x1000,
    dContactApprox1_2 = 0x2000,
    dContactApprox1 = 0x3000
}

struct dSurfaceParameters
{
    int mode;
    dReal mu;
    dReal mu2;
    dReal bounce;
    dReal bounce_vel;
    dReal soft_erp;
    dReal soft_cfm;
    dReal motion1, motion2, motionN;
    dReal slip1, slip2;
}

struct dContactGeom
{
    dVector3 pos;
    dVector3 normal;
    dReal depth;
    dGeomID g1, g2;
    int side1, side2;
}

struct dContact
{
    dSurfaceParameters surface;
    dContactGeom geom;
    dVector3 fdir1;
}

// error.h
extern(C) alias void function(int, char*, va_list ap) dMessageFunction;

// mass.h
struct dMass
{
    dReal mass;
    dVector3 C;
    dMatrix3 I;
}

// memory.h
extern(C)
{
    alias void* function(size_t) dAllocFunction;
    alias void* function(void*, size_t, size_t) dReallocFunction;
    alias void function(void*, size_t) dFreeFunction;
}

// odeinit.h
enum : uint
{
    dInitFlagManualThreadCleanup = 0x00000001
}

enum : uint
{
    dAllocateFlagsBasicData = 0,
    dAllocateFlagsCollisionData = 0x00000001,
    dAllocateMaskAll = ~0U,
}

// timer.h
struct dStopwatch
{
    double time;
    uint cc[2];
}